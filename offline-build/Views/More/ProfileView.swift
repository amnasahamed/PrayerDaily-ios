import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: SalahStore
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.colorScheme) var cs

    @AppStorage("profileName") private var profileName: String = "Muslim"
    @AppStorage("profileLocation") private var profileLocation: String = ""
    @AppStorage("profileMadhab") private var profileMadhab: String = "Hanafi"
    @State private var isEditingName = false
    @State private var isEditingLocation = false
    @State private var tempName = ""
    @State private var tempLocation = ""

    private let madhhabs = ["Hanafi", "Maliki", "Shafi'i", "Hanbali"]

    var body: some View {
        ZStack {
            CalmingBackground().ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    avatarSection
                    statsSection
                    settingsSection
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(localization.t(.profileTitle))
        .navigationBarTitleDisplayMode(.large)
        .modifier(AlehaNavStyle())
    }

    // MARK: - Avatar
    private var avatarSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.alehaGreen, Color.alehaDarkGreen],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                Text(profileName.prefix(1).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }

            if isEditingName {
                HStack {
                    TextField(localization.t(.profileEditName), text: $tempName)
                        .textFieldStyle(.plain)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                    Button(localization.t(.profileSave)) {
                        profileName = tempName.isEmpty ? "Muslim" : tempName
                        isEditingName = false
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.alehaGreen)
                }
                .padding(.horizontal, 40)
            } else {
                Button {
                    tempName = profileName
                    isEditingName = true
                } label: {
                    HStack(spacing: 6) {
                        Text(profileName).font(.title3.weight(.semibold))
                        Image(systemName: "pencil").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            Text("\(localization.t(.profileMemberSince)) \(memberSince)").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    private var memberSince: String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        return f.string(from: Date())
    }

    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 0) {
            profileStat(value: "\(store.currentStreak)", label: localization.t(.profileStreak), icon: "flame.fill", color: .orange)
            Divider().frame(height: 44)
            profileStat(value: "\(store.weeklyConsistency)%", label: localization.t(.profileThisWeek), icon: "chart.bar.fill", color: Color.alehaGreen)
            Divider().frame(height: 44)
            let total = store.logs.values.reduce(0) { $0 + $1.completedCount }
            profileStat(value: "\(total)", label: localization.t(.profilePrayers), icon: "checkmark.seal.fill", color: Color.alehaAmber)
        }
        .noorCard()
    }

    private func profileStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption).foregroundStyle(color)
                Text(value).font(.title3.weight(.bold))
            }
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Settings
    private var settingsSection: some View {
        VStack(spacing: 0) {
            locationRow
            Divider().padding(.leading, 16)
            madhabRow
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .onChange(of: profileMadhab) { _, newMadhab in
            PrayerTimesService.shared.applyMadhab(newMadhab)
        }
    }

    private var locationRow: some View {
        HStack(spacing: 14) {
            rowIcon("location.fill", color: Color.alehaGreen)
            VStack(alignment: .leading, spacing: 2) {
                Text(localization.t(.profileLocation)).font(.subheadline.weight(.medium))
                if isEditingLocation {
                    TextField(localization.t(.profileCityCountry), text: $tempLocation, onCommit: {
                        profileLocation = tempLocation
                        isEditingLocation = false
                    })
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    Text(profileLocation.isEmpty ? localization.t(.commonNotSet) : profileLocation)
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                if isEditingLocation {
                    profileLocation = tempLocation
                    isEditingLocation = false
                } else {
                    tempLocation = profileLocation
                    isEditingLocation = true
                }
            } label: {
                Text(isEditingLocation ? localization.t(.profileSave) : localization.t(.profileEdit))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.alehaGreen)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }

    private var madhabRow: some View {
        HStack(spacing: 14) {
            rowIcon("book.fill", color: Color.alehaAmber)
            Text(localization.t(.profileMadhab)).font(.subheadline.weight(.medium))
            Spacer()
            Picker(localization.t(.profileMadhab), selection: $profileMadhab) {
                ForEach(madhhabs, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
            .font(.caption)
            .tint(Color.alehaGreen)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }

    private func rowIcon(_ name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.12)).frame(width: 32, height: 32)
            Image(systemName: name).font(.system(size: 14)).foregroundStyle(color)
        }
    }
}
