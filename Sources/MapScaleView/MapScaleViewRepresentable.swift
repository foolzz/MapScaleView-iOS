import SwiftUI

/// SwiftUI wrapper for MapScaleView.
///
/// Usage:
///   MapScaleViewRepresentable(zoom: $zoom, latitude: $latitude)
///       .fixedSize()
public struct MapScaleViewRepresentable: UIViewRepresentable {

    public var zoom: Float
    public var latitude: Double
    public var mode: MapScaleView.UnitMode
    public var color: UIColor
    public var textSize: CGFloat
    public var strokeWidth: CGFloat
    public var outlineEnabled: Bool
    public var maxWidth: CGFloat

    public init(
        zoom: Float,
        latitude: Double,
        mode: MapScaleView.UnitMode = .metersAndMiles,
        color: UIColor = UIColor(white: 0.2, alpha: 1),
        textSize: CGFloat = 12,
        strokeWidth: CGFloat = 1.5,
        outlineEnabled: Bool = true,
        maxWidth: CGFloat = 175
    ) {
        self.zoom = zoom
        self.latitude = latitude
        self.mode = mode
        self.color = color
        self.textSize = textSize
        self.strokeWidth = strokeWidth
        self.outlineEnabled = outlineEnabled
        self.maxWidth = maxWidth
    }

    public func makeUIView(context: Context) -> MapScaleView {
        let view = MapScaleView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }

    public func updateUIView(_ uiView: MapScaleView, context: Context) {
        uiView.setColor(color)
        uiView.setTextSize(textSize)
        uiView.setStrokeWidth(strokeWidth)
        uiView.setOutlineEnabled(outlineEnabled)
        uiView.setMaxWidth(maxWidth)
        switch mode {
        case .metersOnly:   uiView.metersOnly()
        case .milesOnly:    uiView.milesOnly()
        case .metersAndMiles: uiView.metersAndMiles()
        @unknown default:   uiView.metersAndMiles()
        }
        uiView.update(zoom: zoom, latitude: latitude)
    }
}
