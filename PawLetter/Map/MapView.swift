//
//  MapView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 11.08.2026.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var focusCoordinate: CLLocationCoordinate2D?
    @State private var mapViewModel = MapViewModel()
    @State private var isShowingFilterSheet = false
    
    @State private var pinTapped = false
    @State private var radiusSelected = false
    @State private var filterTapped = false
    @State private var satelliteToggled = false
    @State private var recenterTapped = false
    @State private var filterOptionToggled = false
    
    var letters: [Letter]
    let pairID: String
    var currentUserID: String?
    var partnerName: String?
    var locationService: LocationService
    var eventsViewModel: PairEventsViewModel
    
    var lettersWithLocation: [Letter] {
        letters.filter { $0.location != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                mapContent
                    .ignoresSafeArea(edges: .all)
                    .safeAreaInset(edge: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Memories Map")
                                    .font(.largeTitle.bold())
                                Text("\(lettersWithLocation.count) memories with \(partnerName ?? "your partner")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    nearbyMenu
                                    filterButton
                                    satelliteButton
                                    recenterButton
                                }
                            }
                            .mask(
                                LinearGradient(
                                    stops: [
                                        .init(color: .black, location: 0),
                                        .init(color: .black, location: 0.9),
                                        .init(color: .clear, location: 1)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 15)
                        .padding(.top, 25)
                    }
                
                if let selectedLetter = mapViewModel.selectedLetter {
                    MemoryPreviewCard(
                        letter: selectedLetter,
                        onOpen: {
                            mapViewModel.letterToOpen = mapViewModel.selectedLetter
                        }
                    )
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
            }
            .onAppear {
                if !mapViewModel.hasSetInitialPosition && !lettersWithLocation.isEmpty {
                    mapViewModel.position = .automatic
                    mapViewModel.hasSetInitialPosition = true
                }
                locationService.requestCurrentLocation()
            }
            .onChange(of: focusCoordinate) { oldValue, newCoordinate in
                guard let newCoordinate else { return }
                mapViewModel.position = .region(
                    MKCoordinateRegion(
                        center: newCoordinate,
                        latitudinalMeters: 1500,
                        longitudinalMeters: 1500
                    )
                )
                focusCoordinate = nil
            }
            .sheet(isPresented: $isShowingFilterSheet) {
                NavigationStack {
                    List {
                        ForEach(MapFilterOption.allCases, id: \.self) { option in
                            Button {
                                filterOptionToggled.toggle()
                                mapViewModel.toggleFilter(option)
                            } label: {
                                HStack {
                                    Text(option.title)
                                    Spacer()
                                    if mapViewModel.selectedFilters.contains(option) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                    .navigationTitle("Filter memories")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isShowingFilterSheet = false
                            }
                        }
                    }
                }
                .sensoryFeedback(.selection, trigger: filterOptionToggled)
                .presentationDetents([.medium])
            }
            .navigationDestination(item: $mapViewModel.letterToOpen) { letter in
                LetterDetailView(
                    letter: letter,
                    pairID: pairID,
                    currentUserID: currentUserID,
                    partnerName: partnerName,
                    locationService: locationService,
                    eventsViewModel: eventsViewModel,
                    onOpenLocationInMap: { coordinate in
                        focusCoordinate = coordinate
                    }
                )
            }
            .navigationBarHidden(true)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: pinTapped)
        .sensoryFeedback(.selection, trigger: radiusSelected)
        .sensoryFeedback(.impact(weight: .light), trigger: filterTapped)
        .sensoryFeedback(.impact(weight: .light), trigger: satelliteToggled)
        .sensoryFeedback(.impact(weight: .light), trigger: recenterTapped)
    }
    private var mapContent: some View {
        Map(position: $mapViewModel.position) {
            UserAnnotation()
            ForEach(Array(mapViewModel.filteredLetters(from: lettersWithLocation).enumerated()), id: \.element.id) { index, letter in
                if let location = letter.location {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    Annotation(letter.subject, coordinate: coordinate) {
                        MemoryMapPin(
                            isSelected: mapViewModel.selectedLetter?.id == letter.id,
                            mood: letter.mood,
                            surprise: letter.surprise,
                            appearDelay: Double(index) * 0.1
                        )
                        .onTapGesture {
                            pinTapped.toggle()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                if mapViewModel.selectedLetter?.id == letter.id {
                                    mapViewModel.selectedLetter = nil
                                } else {
                                    mapViewModel.selectedLetter = letter
                                }
                            }
                        }
                    }
                }
            }
        }
        .mapStyle(mapViewModel.isSatelliteStyle ? .imagery(elevation: .realistic) : .standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .mapControls {}
    }
    private var nearbyMenu: some View {
        Menu {
            ForEach(MapViewModel.NearbyRadius.allCases, id: \.self) { radius in
                Button{
                    radiusSelected.toggle()
                    mapViewModel.selectedRadius = radius
                    if let userCoordinate = locationService.userLocation {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            mapViewModel.position = .region(
                                MKCoordinateRegion(
                                    center: userCoordinate,
                                    latitudinalMeters: radius.rawValue * 2,
                                    longitudinalMeters: radius.rawValue * 2
                                )
                            )
                        }
                    }
                } label: {
                    if radius == mapViewModel.selectedRadius{
                        Label(radius.title, systemImage: "checkmark")
                    } else {
                        Text(radius.title)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                if let nearbyCount = mapViewModel.nearbyCount(from: lettersWithLocation, locationService) {
                    Text("\(nearbyCount) nearby")
                } else {
                    Text("Nearby")
                }
            }
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
    }
    private var filterButton: some View {
        Button {
            filterTapped.toggle()
            isShowingFilterSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Filter")
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
    }
    private var satelliteButton: some View {
        Button {
            satelliteToggled.toggle()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                mapViewModel.isSatelliteStyle.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: mapViewModel.isSatelliteStyle ? "map.fill" : "globe.americas.fill")
                Text(mapViewModel.isSatelliteStyle ? "Standard" : "Satellite")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.accentColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
    }
    private var recenterButton: some View {
        Button {
            recenterTapped.toggle()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                mapViewModel.position = .userLocation(fallback: .automatic)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                Text("Recenter")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.accentColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
    }
}
#Preview {
    MapView(
        focusCoordinate: .constant(nil),
             letters: [],
             pairID: "1234567890",
             currentUserID: "nazarLOX",
             partnerName: "nastia",
             locationService: LocationService(),
             eventsViewModel: PairEventsViewModel()
    )
}
