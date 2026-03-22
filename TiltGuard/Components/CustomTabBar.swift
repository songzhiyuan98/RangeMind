import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let lang: AppLanguage
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var namespace

    private struct TabDef {
        let index: Int
        let icon: String
        let iconFill: String
        let key: L10n.Key
    }

    private let tabs: [TabDef] = [
        TabDef(index: 0, icon: "house",     iconFill: "house.fill",     key: .tabHome),
        TabDef(index: 1, icon: "bolt",      iconFill: "bolt.fill",      key: .tabLive),
        TabDef(index: 2, icon: "chart.bar", iconFill: "chart.bar.fill", key: .tabStats),
        TabDef(index: 3, icon: "person",    iconFill: "person.fill",    key: .tabMe),
    ]

    // Selected pill text: black on dark mode, white on light mode
    private var selectedForeground: Color {
        colorScheme == .dark ? .black : .white
    }

    // Unselected icon color - slightly brighter for better visibility
    private var unselectedForeground: Color {
        colorScheme == .dark
            ? .white.opacity(0.4)
            : .black.opacity(0.35)
    }

    // Glass border - subtle top highlight for depth
    private var glassBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(colorScheme == .dark ? 0.18 : 0.6),
                .white.opacity(colorScheme == .dark ? 0.04 : 0.15)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs, id: \.index) { tab in
                tabButton(tab)
            }
        }
        .padding(5)
        .fixedSize(horizontal: true, vertical: true)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(glassBorderGradient, lineWidth: 0.5)
                )
                .overlay(
                    // Inner shadow for depth
                    Capsule()
                        .stroke(.black.opacity(colorScheme == .dark ? 0.3 : 0.06), lineWidth: 0.5)
                        .blur(radius: 1)
                        .offset(y: 1)
                        .mask(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.black, .clear],
                                        startPoint: .bottom,
                                        endPoint: .center
                                    )
                                )
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 16, y: 6)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        )
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    @ViewBuilder
    private func tabButton(_ tab: TabDef) -> some View {
        let isSelected = selectedTab == tab.index

        Button {
            guard !isSelected else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = tab.index
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? tab.iconFill : tab.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .symbolEffect(.bounce, value: isSelected)

                if isSelected {
                    Text(L10n.s(tab.key, lang))
                        .font(.system(size: 13, weight: .bold))
                        .transition(.blurReplace)
                }
            }
            .foregroundStyle(isSelected ? selectedForeground : unselectedForeground)
            .padding(.horizontal, isSelected ? 16 : 14)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.vtAccent,
                                    Color.vtAccent.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .matchedGeometryEffect(id: "pill", in: namespace)
                        .shadow(color: Color.vtAccent.opacity(0.4), radius: 8, y: 3)
                        .shadow(color: Color.vtAccent.opacity(0.15), radius: 2, y: 1)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
