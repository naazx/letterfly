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
    @State private var position: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.8397, longitude: 24.0297),
                latitudinalMeters: 3000,
                longitudinalMeters: 3000
            )
        )
    )
    @State private var isSatelliteStyle: Bool = false
    @State private var hasSetInitialPosition = false
    
    var letters: [Letter]
    var homeViewModel: HomeViewModel
    let pairID: String
    var currentUserID: String?
    var partnerName: String?
    
    var lettersWithLocation: [Letter] {
        letters.filter { $0.location != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $position) {
                    UserAnnotation()
                    
                    ForEach(lettersWithLocation) { letter in
                        if let location = letter.location {
                            let coordinate = CLLocationCoordinate2D(
                                latitude: location.latitude,
                                longitude: location.longitude
                            )
                            
                            Annotation(letter.subject, coordinate: coordinate) {
                                NavigationLink(destination: LetterDetailView(letter: letter, pairID: pairID, currentUserID: currentUserID, partnerName: partnerName, onOpenLocationInMap: { coordinate in
                                    focusCoordinate = coordinate
                                })) {
                                    ZStack {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 44, height: 44)
                                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                                        
                                        Image(systemName: "envelope.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                        }
                    }
                    
                }
                .mapStyle(isSatelliteStyle ? .imagery(elevation: .realistic) : .standard(elevation: .realistic, pointsOfInterest: .excludingAll))
                .mapControls {}
                .ignoresSafeArea(edges: .all)
                .safeAreaInset(edge: .top) {
                        Text("Memories Map")
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 15)
                            .padding(.top, 25)
                }
                
                VStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            isSatelliteStyle.toggle()
                        }
                    } label: {
                        Image(systemName: isSatelliteStyle ? "map.fill" : "globe.americas.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            position = .userLocation(fallback: .automatic)
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 50)
            }
            .onAppear {
                if !hasSetInitialPosition && !lettersWithLocation.isEmpty {
                    position = .automatic
                    hasSetInitialPosition = true
                }
            }
            .onChange(of: focusCoordinate) { oldValue, newCoordinate in
                guard let newCoordinate else { return }
                position = .region(MKCoordinateRegion(center: newCoordinate, latitudinalMeters: 1500, longitudinalMeters: 1500))
                focusCoordinate = nil
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MapView( focusCoordinate: .constant(nil),
             letters: [],
             homeViewModel: HomeViewModel(),
             pairID: "1234567890",
             currentUserID: "nazarLOX",
             partnerName: "nastia")
}
