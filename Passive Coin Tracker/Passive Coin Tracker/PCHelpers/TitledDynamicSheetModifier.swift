//
//  TitledDynamicSheetModifier.swift
//  Passive Coin Tracker
//
//


import SwiftUI

// MARK: - View Modifier

private struct TitledDynamicSheetModifier<SheetContent: View>: ViewModifier {
    let image: ImageResource?
    let title: String
    @Binding var isPresented: Bool
    let content: () -> SheetContent

    @State private var measuredHeight: CGFloat = 200

    func body(content base: Content) -> some View {
        base.sheet(isPresented: $isPresented) {
            TitledDynamicSheet(
                image: image,
                title: title,
                isPresented: $isPresented,
                measuredHeight: $measuredHeight,
                content: self.content
            )
            .presentationDetents([.height(clamp(measuredHeight, min: 120, max: UIScreen.main.bounds.height * 0.9))])
            .presentationDragIndicator(.visible)
        }
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }
}

// MARK: - Sheet Container

private struct TitledDynamicSheet<SheetContent: View>: View {
    let image: ImageResource?
    let title: String
    @Binding var isPresented: Bool
    @Binding var measuredHeight: CGFloat
    let content: () -> SheetContent

    // Отступы/элементы шапки учитываем в общей высоте
    private let headerHeightEstimate: CGFloat = 56
    private let verticalPadding: CGFloat = 24

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, 8)

            RoundedRectangle(cornerRadius: 2)
                .frame(height: 1)
                .foregroundStyle(.progressSecondary)

            // Контент
            VStack(alignment: .leading, spacing: 0) {
                self.content()
                    .padding(16)
            }
            .background(
                HeightReader { contentHeight in
                    // Общая высота = шапка + контент + паддинги/дивидеры
                    let total = headerHeightEstimate + contentHeight + verticalPadding
                    if abs(total - measuredHeight) > 1 {
                        measuredHeight = total
                    }
                }
            )
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.progressSecondary))
    }

    private var header: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                if let image {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .bold()
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Height Reader Helper

private struct HeightReader: View {
    var onChange: (CGFloat) -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: HeightPreferenceKey.self, value: proxy.size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Public API

extension View {
    func titledSheet<SheetContent: View>(
        image: ImageResource? = nil,
        title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(TitledDynamicSheetModifier(image: image, title: title, isPresented: isPresented, content: content))
    }
}
