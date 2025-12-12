import SwiftUI
import CoreLocation

/// Sheet to save a confirmed address with label and landmark
struct SaveAddressSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userViewModel: UserViewModel
    
    // Address details passed from confirmation
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    // User inputs
    @State private var selectedLabel: String = "Home"
    @State private var customLabel: String = ""
    @State private var landmark: String = ""
    @State private var isDefault: Bool = false
    @State private var isSaving: Bool = false
    @State private var showCustomLabel: Bool = false
    
    // Preset labels
    private let presetLabels = ["Home", "Work", "Gym", "Hotel", "Other"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Address Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DELIVERY ADDRESS")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color("primaryGreen"))
                            
                            Text(address)
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .lineLimit(3)
                        }
                        .padding(16)
                        .background(Color.gray.opacity(0.06))
                        .cornerRadius(12)
                    }
                    
                    // MARK: - Label Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SAVE AS")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        // Preset label chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(presetLabels, id: \.self) { label in
                                    LabelChip(
                                        label: label,
                                        isSelected: selectedLabel == label,
                                        action: {
                                            selectedLabel = label
                                            showCustomLabel = (label == "Other")
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Custom label input
                        if showCustomLabel {
                            HStack(spacing: 12) {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                TextField("Enter custom label", text: $customLabel)
                                    .font(.system(size: 15))
                            }
                            .padding(14)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(10)
                        }
                    }
                    
                    // MARK: - Landmark
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LANDMARK (OPTIONAL)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            TextField("E.g., Near HDFC Bank", text: $landmark)
                                .font(.system(size: 15))
                        }
                        .padding(14)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(10)
                    }
                    
                    // MARK: - Default Toggle
                    Toggle(isOn: $isDefault) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color("primaryYellow"))
                                .font(.system(size: 16))
                            Text("Set as default address")
                                .font(.system(size: 15))
                        }
                    }
                    .tint(Color("primaryGreen"))
                    .padding(.vertical, 8)
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .navigationTitle("Save Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Save Button
                Button(action: saveAddress) {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                            Text("Save Address")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("primaryGreen"))
                    .cornerRadius(12)
                }
                .disabled(isSaving)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(Color.white)
            }
        }
    }
    
    // MARK: - Save Action
    private func saveAddress() {
        let finalLabel = showCustomLabel ? customLabel : selectedLabel
        guard !finalLabel.isEmpty else { return }
        
        isSaving = true
        
        userViewModel.addAddress(
            title: finalLabel,
            fullAddress: address,
            landmark: landmark.isEmpty ? nil : landmark,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            isDefault: isDefault
        ) { success in
            isSaving = false
            if success {
                print("💾 Address saved: \(finalLabel)")
                isPresented = false
            }
        }
    }
}

// MARK: - Label Chip Component
struct LabelChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    private var icon: String {
        switch label.lowercased() {
        case "home": return "house.fill"
        case "work": return "briefcase.fill"
        case "gym": return "dumbbell.fill"
        case "hotel": return "building.2.fill"
        default: return "plus"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color("primaryGreen") : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SaveAddressSheet(
        isPresented: .constant(true),
        address: "Kondapur, Hyderabad, Telangana",
        coordinate: CLLocationCoordinate2D(latitude: 17.4639, longitude: 78.3489)
    )
    .environmentObject(UserViewModel())
}
