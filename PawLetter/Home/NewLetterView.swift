//
//  NewLetterView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import PhotosUI
import MapKit
import SwiftUI

struct NewLetterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = NewLetterViewModel()
    @State private var audioRecorder = AudioRecorderService()
    @State private var editedLocationName: String?
    @State private var isAddingLocation: Bool = false
    @State private var selectedLocation: Letter.LetterLocation?
    @State private var selectedItem: PhotosPickerItem?
    @State private var pulseScale: CGFloat = 1.0
    @State private var isShowingSendAnimation: Bool = false
    
    @State private var isEnvelopeOpen: Bool = true
    @State private var envelopeScale: CGFloat = 0.3
    @State private var envelopeOffset: CGSize = .zero
    @State private var envelopeOpacity: Double = 1
    @State private var envelopeRotation: Double = 0
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        latitudinalMeters: 3000,
        longitudinalMeters: 3000
    )
    @State private var isChoosingOnMap: Bool = false
    @State private var tappedCoordinate: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isLoadingLocation: Bool = false
    
    let existingLetter: Letter?
    var pairID: String
    var authorID: String
    var locationService: LocationService
    
    enum Field {
        case subject
        case letter
    }
    @FocusState private var focusedField: Field?
    
    init(existingLetter: Letter?, pairID: String, authorID: String, locationService: LocationService) {
        self.existingLetter = existingLetter
        self.pairID = pairID
        self.authorID = authorID
        self.locationService = locationService
        _viewModel = State(initialValue: NewLetterViewModel(existingLetter: existingLetter))
    }
    
    var body: some View {
        NavigationStack{
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        photoSection
                        
                        titleSection
                        
                        inputModePicker
                    
                        if viewModel.inputMode == .text {
                            textSection
                        } else {
                            voiceSection
                        }
                        
                        locationSection
                        
                        moodSection
                        
                        giftSection
                }
                    .padding(20)
            }
                .toolbar {
                    keyboardToolbar
                    confirmationToolbarItem
                    cancellationToolbarItem
                }
                .alert("Error", isPresented: $viewModel.showError) {
                    Button("OK") {}
                } message: {
                    Text(viewModel.errorMessage)
                }
                .onChange(of: viewModel.isSuccess){ _, _ in
                    if existingLetter == nil {
                        isShowingSendAnimation = true
                        Task {
                            try? await Task.sleep(for: .seconds(3.0))
                            dismiss()
                        }
                    } else {
                        dismiss()
                    }
                }
                .task {
                    await viewModel.loadExistingPhoto()
                    if let audioURLString = existingLetter?.audioURL {
                        await audioRecorder.loadRemoteRecording(from: audioURLString)
                    }
                }
                .confirmationDialog("Location Options", isPresented: $isAddingLocation) {
                    Button("Use current", systemImage: "location.fill") {
                            locationService.requestPermission()
                            locationService.requestCurrentLocation()
                    }
                    Button("Choose on map", systemImage: "map") {
                        isLoadingLocation = true
                        isChoosingOnMap = true
                        locationService.requestPermission()
                        locationService.requestCurrentLocation()
                        
                        Task {
                            try? await Task.sleep(for: .seconds(3))
                            isLoadingLocation = false
                        }
                    }
                }
                .onChange(of: locationService.userLocation) { oldValue, newLocation in
                    guard let newLocation else { return }
                    if isLoadingLocation {
                        mapRegion = MKCoordinateRegion(center: newLocation, latitudinalMeters: 3000, longitudinalMeters: 3000)
                        cameraPosition = .region(mapRegion)
                        isLoadingLocation = false
                    } else if !isChoosingOnMap{
                        selectedLocation = Letter.LetterLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
                        Task {
                            editedLocationName = await locationService.placeName(for: newLocation)
                        }
                    } else {}
                }
                .sheet(isPresented: $isChoosingOnMap) {
                    chooseOnMapLocation
                }
                .onChange(of: selectedItem){  _ , newValue in
                    if let newValue {
                        Task{
                            try? await viewModel.loadPreview(item: newValue)
                        }
                    } else {}
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle(existingLetter == nil ? "New letter" : "Edit letter")
                .navigationBarTitleDisplayMode(.inline)
        }
        .overlay {
            if isShowingSendAnimation {
                Color(.systemBackground)
                    .opacity(0.95)
                    .ignoresSafeArea()
                    .overlay {
                        ZStack {
                            Image(systemName: "envelope.open.fill")
                                .opacity(isEnvelopeOpen ? 1 : 0)
                            Image(systemName: "envelope.fill")
                                .opacity(isEnvelopeOpen ? 0 : 1)
                        }
                        .font(.system(size: 70))
                        .foregroundStyle(Color.accentColor)
                        .scaleEffect(envelopeScale)
                        .rotationEffect(.degrees(envelopeRotation))
                        .offset(envelopeOffset)
                        .opacity(envelopeOpacity)
                    }
                    .task {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            envelopeScale = 1.0
                        }
                        try? await Task.sleep(for: .seconds(0.5))

                        withAnimation(.easeInOut(duration: 0.25)) {
                            isEnvelopeOpen = false
                            envelopeScale = 0.85
                        }
                        try? await Task.sleep(for: .seconds(0.25))
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                            envelopeScale = 1.0
                        }
                        try? await Task.sleep(for: .seconds(0.25))

                        withAnimation(.easeInOut(duration: 0.08)) { envelopeRotation = -6 }
                        try? await Task.sleep(for: .seconds(0.08))
                        withAnimation(.easeInOut(duration: 0.08)) { envelopeRotation = 6 }
                        try? await Task.sleep(for: .seconds(0.08))
                        withAnimation(.easeInOut(duration: 0.08)) { envelopeRotation = 0 }
                        try? await Task.sleep(for: .seconds(0.1))

                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                        withAnimation(.easeOut(duration: 0.3)) {
                            envelopeOffset = CGSize(width: 40, height: -160)
                            envelopeRotation = 15
                            envelopeScale = 0.8
                        }
                        try? await Task.sleep(for: .seconds(0.3))
                        withAnimation(.easeIn(duration: 0.35)) {
                            envelopeOffset = CGSize(width: 180, height: -230)
                            envelopeRotation = 30
                            envelopeScale = 0.3
                            envelopeOpacity = 0
                        }
                    }
            }
        }
        .interactiveDismissDisabled(isShowingSendAnimation)
    }
    private var photoSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {

            if let previewImage = viewModel.previewImage {

                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .contentShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
                    .overlay(alignment: .topTrailing) {
                        if viewModel.previewImage != nil || existingLetter?.photoURL != nil {

                            Button {
                                viewModel.didRemovePhoto = true
                                selectedItem = nil
                                viewModel.previewImage = nil
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .padding()
                        }

                    }
            } else {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 240)
                    .overlay {

                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.largeTitle)

                            Text("Choose Photo")
                                .font(.headline)
                        }
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TITLE")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            TextField("Birthday in the mountains", text: $viewModel.subject)
                .focused($focusedField, equals: .subject)
                .font(.title3.weight(.semibold))
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .submitLabel(.next)
                .onSubmit { focusedField = .letter }
        }
    }

    private var inputModePicker: some View {
        Picker("Input Mode", selection: $viewModel.inputMode) {
            Text("Text").tag(NewLetterViewModel.InputMode.text)
            Text("Voice").tag(NewLetterViewModel.InputMode.voice)
        }
        .pickerStyle(.segmented)
    }
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("LETTER")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .topLeading) {
                if (viewModel.text ?? "").isEmpty {
                    Text("Write your letter...")
                        .foregroundStyle(.tertiary)
                        .padding(.top, 16)
                        .padding(.leading, 14)
                }
                
                TextEditor(text: Binding(
                    get: { viewModel.text ?? "" },
                    set: { viewModel.text = $0 }
                ))
                .focused($focusedField, equals: .letter)
                .frame(minHeight: 260)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
            }
        }
    }
    private var voiceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("VOICE MESSAGE")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 16) {
                if audioRecorder.isRecording {
                    recordingState
                } else if audioRecorder.recordingURL != nil {
                    playbackState
                } else {
                    startState
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var startState: some View {
        Button {
            audioRecorder.startRecording()
        } label: {
            HStack {
                Image(systemName: "mic.fill")
                Text("Start Recording")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.accentColor)
            .clipShape(Capsule())
        }
    }

    private var recordingState: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .scaleEffect(pulseScale)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseScale)
                    .onAppear { pulseScale = 1.4 }
                
                Text(audioRecorder.formattedDuration)
                    .font(.headline.monospacedDigit())
            }
            
            Button {
                audioRecorder.stopRecording()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
    }

    private var playbackState: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                Button {
                    audioRecorder.isPlaying ? audioRecorder.stopPlayback() : audioRecorder.startPlayback()
                } label: {
                    Image(systemName: audioRecorder.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
                
                Text(audioRecorder.formattedDuration)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 20) {
                Button {
                    audioRecorder.deleteRecording()
                    audioRecorder.startRecording()
                } label: {
                    Label("Record Again", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                }
                
                Button(role: .destructive) {
                    audioRecorder.deleteRecording()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.subheadline)
                }
            }
        }
    }
    private var locationSection: some View {
        Group {
            if selectedLocation == nil {
                Button {
                    isAddingLocation = true
                } label: {
                    Label("Add location", systemImage: "mappin.circle")
                }
            } else {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.accentColor)
                    
                    Text(editedLocationName ?? "Location added")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    Button {
                        selectedLocation = nil
                        editedLocationName = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MOOD")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            ChipPicker<MoodType>(selection: $viewModel.mood, options: MoodType.allCases)
        }
    }
    private var giftSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("GIFTS")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            ChipPicker<SurpriseType>(selection: $viewModel.surprise, options: viewModel.surpriseOptions)
        }
    }
    private var isSendDisabled: Bool {
        if viewModel.subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        if viewModel.inputMode == .text {
            return (viewModel.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        if viewModel.inputMode == .voice {
            return audioRecorder.recordingURL == nil
        }
        return false
    }
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                focusedField = nil
            }
        }
    }

    private var sendButton: some View {
        Button(existingLetter == nil ? "Send" : "Save") {
            let finalLocation: Letter.LetterLocation? = selectedLocation.map {
                Letter.LetterLocation(placeName: editedLocationName, latitude: $0.latitude, longitude: $0.longitude)
                }
            Task {
                await viewModel.send(
                    pairID: pairID,
                    authorID: authorID,
                    recordingURL: audioRecorder.recordingURL,
                    location: finalLocation
                )
            }
        }
        .disabled(isSendDisabled)
        .animation(.easeInOut(duration: 0.2), value: viewModel.subject)
        .animation(.easeInOut(duration: 0.2), value: viewModel.text)
    }

    private var confirmationToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            sendButton
        }
    }

    private var cancellationToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
    private var chooseOnMapLocation: some View {
        NavigationStack{
            Group {
                if isLoadingLocation {
                    PawLoadingView()
                } else {
                    MapReader { proxy in
                        Map(position: $cameraPosition) {
                            if let tappedCoordinate {
                                Marker("Selected Place", coordinate: tappedCoordinate)
                                    .tint(Color.accentColor)
                            }
                            UserAnnotation()
                                .tint(.blue)
                        }
                        .mapControls {
                            MapUserLocationButton()
                        }
                        .onTapGesture { screenPoint in
                            if let coordinate = proxy.convert(screenPoint, from: .local) {
                                tappedCoordinate = coordinate
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        guard let tappedCoordinate else { return }
                        selectedLocation = Letter.LetterLocation(latitude: tappedCoordinate.latitude, longitude: tappedCoordinate.longitude)
                        isChoosingOnMap = false
                        Task {
                            editedLocationName = await locationService.placeName(for: tappedCoordinate)
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        tappedCoordinate = nil
                        isChoosingOnMap = false
                    }
                }
            }
        }
    }
}
#Preview {
    NewLetterView(
        existingLetter: nil,
        pairID: "qJ23Kdi6EMFLYmtnWgiD",
        authorID: "3z34vv",
        locationService: LocationService()
    )
}
