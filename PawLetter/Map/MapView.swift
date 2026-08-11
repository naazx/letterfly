//
//  MapView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 11.08.2026.
//

import SwiftUI

import SwiftUI
import MapKit

struct MapView: View {
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
    
    var letters: [Letter]
    var homeViewModel: HomeViewModel
    
    var letterWithLocation: [Letter] {
        letters.filter { $0.location != nil }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position) {
                ForEach(letterWithLocation) { letter in
                    
                }
            }
                .mapStyle(isSatelliteStyle ? .imagery(elevation: .realistic) : .standard(elevation: .realistic, pointsOfInterest: .excludingAll))
                .mapControls {}
                .ignoresSafeArea(edges: .all)
            
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
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    MapView(letters: [], homeViewModel: HomeViewModel())
}
