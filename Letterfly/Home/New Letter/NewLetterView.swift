//
//  NewLetterView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import PhotosUI
import MapKit
import SwiftUI

private struct PressScaleEffect: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

private extension View {
    func pressScaleEffect() -> some View {
        modifier(PressScaleEffect())
    }
}

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
    
    @State private var scheduleOption: ScheduleOption = .sendNow
    @State private var customUnlockDate: Date = .now
    @State private var selectedLinkedEventID: String?
    
    @State private var photoRemoved = false
    @State private var recordingStarted = false
    @State private var recordingStopped = false
    @State private var voicePlaybackToggled = false
    @State private var recordingDeleted = false
    @State private var locationRemoved = false
    @State private var locationOptionTapped = false
    @State private var sendTapped = false
    @State private var cancelTapped = false
    @State private var moodChanged = false
    @State private var surpriseChanged = false
    
    let existingLetter: Letter?
    var pairID: String
    var authorID: String
    var locationService: LocationService
    var eventsViewModel: PairEventsViewModel
    
    enum Field {
        case subject
        case letter
    }
    @FocusState private var focusedField: Field?
    
    enum ScheduleOption: CaseIterable {
        case sendNow, customDate, linkToEvent
    }
    
    init(existingLetter: Letter?, pairID: String, authorID: String, locationService: LocationService,  eventsViewModel: PairEventsViewModel) {
        self.existingLetter = existingLetter
        self.pairID = pairID
        self.authorID = authorID
        self.locationService = locationService
        self.eventsViewModel = eventsViewModel
        _viewModel = State(initialValue: NewLetterViewModel(existingLetter: existingLetter))
        
        if let linkedEventID = existingLetter?.linkedEventID {
            self._scheduleOption = State(initialValue: .linkToEvent)
            self._selectedLinkedEventID = State(initialValue: linkedEventID)
        } else if let unlockDate = existingLetter?.unlockDate {
            self._scheduleOption = State(initialValue: .customDate)
            self._customUnlockDate = State(initialValue: unlockDate)
        } else {
            self._scheduleOption = State(initialValue: .sendNow)
        }
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
                        
                        scheduleSection
                }
                    .padding(16)
            }
                .background(Color(.systemGroupedBackground))
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
                .onChange(of: viewModel.mood) { _, _ in
                    moodChanged.toggle()
                }
                .onChange(of: viewModel.surprise) { _, _ in
                    surpriseChanged.toggle()
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
                            locationOptionTapped.toggle()
                            locationService.requestPermission()
                            locationService.requestCurrentLocation()
                    }
                    Button("Choose on map", systemImage: "map") {
                        locationOptionTapped.toggle()
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
        .sensoryFeedback(.impact(weight: .medium), trigger: photoRemoved)
        .sensoryFeedback(.impact(weight: .medium), trigger: recordingStarted)
        .sensoryFeedback(.impact(weight: .medium), trigger: recordingStopped)
        .sensoryFeedback(.impact(weight: .light), trigger: voicePlaybackToggled)
        .sensoryFeedback(.impact(weight: .medium), trigger: recordingDeleted)
        .sensoryFeedback(.impact(weight: .light), trigger: locationRemoved)
        .sensoryFeedback(.impact(weight: .light), trigger: locationOptionTapped)
        .sensoryFeedback(.impact(weight: .medium), trigger: sendTapped)
        .sensoryFeedback(.impact(weight: .light), trigger: cancelTapped)
        .sensoryFeedback(.selection, trigger: moodChanged)
        .sensoryFeedback(.selection, trigger: surpriseChanged)
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
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .contentShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
                    .overlay(alignment: .topTrailing) {
                        if viewModel.previewImage != nil || existingLetter?.photoURL != nil {

                            Button {
                                photoRemoved.toggle()
                                viewModel.didRemovePhoto = true
                                selectedItem = nil
                                viewModel.previewImage = nil
                                viewModel.selectedImageData = nil
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .padding()
                        }

                    }
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.secondarySystemGroupedBackground))
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
                .background(Color(.secondarySystemGroupedBackground))
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
                .background(Color(.secondarySystemGroupedBackground))
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
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var startState: some View {
        Button {
            recordingStarted.toggle()
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
                recordingStopped.toggle()
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
                    voicePlaybackToggled.toggle()
                    audioRecorder.isPlaying ? audioRecorder.stopPlayback() : audioRecorder.startPlayback()
                } label: {
                    Image(systemName: audioRecorder.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
                .pressScaleEffect()
                
                Text(audioRecorder.formattedDuration)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 20) {
                Button {
                    recordingDeleted.toggle()
                    audioRecorder.deleteRecording()
                    audioRecorder.startRecording()
                } label: {
                    Label("Record Again", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                }
                
                Button(role: .destructive) {
                    recordingDeleted.toggle()
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
                        locationRemoved.toggle()
                        selectedLocation = nil
                        editedLocationName = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
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
            sendTapped.toggle()
            let finalLocation: Letter.LetterLocation? = selectedLocation.map {
                Letter.LetterLocation(placeName: editedLocationName, latitude: $0.latitude, longitude: $0.longitude)
                }
            Task {
                let finalUnlockDate: Date?
                let finalLinkedEventID: String?

                switch scheduleOption {
                case .sendNow:
                    finalUnlockDate = nil
                    finalLinkedEventID = nil
                case .customDate:
                    finalUnlockDate = Calendar.current.startOfDay(for: customUnlockDate)
                    finalLinkedEventID = nil
                case .linkToEvent:
                    finalLinkedEventID = selectedLinkedEventID
                    let eventDate = eventsViewModel.events.first(where: { $0.id == selectedLinkedEventID })?.nextOccurrence
                    finalUnlockDate = eventDate.map { Calendar.current.startOfDay(for: $0) }
                }
                viewModel.unlockDate = finalUnlockDate
                viewModel.linkedEventID = finalLinkedEventID
                
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
                cancelTapped.toggle()
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
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SENDING")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Picker("Schedule", selection: $scheduleOption) {
                Text("Send now").tag(ScheduleOption.sendNow)
                Text("Custom date").tag(ScheduleOption.customDate)
                Text("Link to event").tag(ScheduleOption.linkToEvent)
            }
            .pickerStyle(.segmented)
            
            switch scheduleOption {
            case .sendNow:
                EmptyView()
            case .customDate:
                DatePicker("Unlock date", selection: $customUnlockDate, displayedComponents: .date)
            case .linkToEvent:
                Picker("Event", selection: $selectedLinkedEventID) {
                    Text("None").tag(String?.none)
                    ForEach(eventsViewModel.events) { event in
                        Text(event.title).tag(event.id)
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
        locationService: LocationService(),
        eventsViewModel: PairEventsViewModel()
    )
}
