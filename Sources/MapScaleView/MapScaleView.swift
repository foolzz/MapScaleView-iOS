import UIKit

/// A UIView that displays a map scale bar, mirroring the Android pengrad/mapscaleview library.
///
/// Usage:
///   let scaleView = MapScaleView()
///   // add to your view hierarchy, then on every camera change:
///   scaleView.update(zoom: position.zoom, latitude: position.target.latitude)
@objc public class MapScaleView: UIView {

    // MARK: - Types

    @objc public enum UnitMode: Int {
        case metersOnly
        case milesOnly
        case metersAndMiles
    }

    // MARK: - Configuration

    private var config = ViewConfig()
    private var mode: UnitMode = .metersAndMiles

    // MARK: - State

    private var currentScales: Scales?
    private lazy var drawer = Drawer(config: config)

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        isOpaque = false
    }

    // MARK: - Public API (mirrors Android)

    /// Update the scale bar for the given map zoom level and latitude.
    /// Call this from your map camera-change callback.
    @objc public func update(zoom: Float, latitude: Double) {
        currentScales = MapScaleModel.scales(
            zoom: zoom,
            latitude: latitude,
            maxWidth: config.maxWidth,
            mode: mode
        )
        if let scales = currentScales {
            let size = drawer.intrinsicSize(for: scales)
            frame.size = size
        }
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
    }

    @objc public func setColor(_ color: UIColor) {
        config.color = color
        drawer = Drawer(config: config)
        setNeedsDisplay()
    }

    @objc public func setOutlineColor(_ color: UIColor) {
        config.outlineColor = color
        drawer = Drawer(config: config)
        setNeedsDisplay()
    }

    @objc public func setTextSize(_ size: CGFloat) {
        config.textSize = size
        drawer = Drawer(config: config)
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }

    @objc public func setStrokeWidth(_ width: CGFloat) {
        config.strokeWidth = width
        drawer = Drawer(config: config)
        setNeedsDisplay()
    }

    @objc public func setOutlineEnabled(_ enabled: Bool) {
        config.outlineEnabled = enabled
        drawer = Drawer(config: config)
        setNeedsDisplay()
    }

    @objc public func setMaxWidth(_ maxWidth: CGFloat) {
        config.maxWidth = maxWidth
        setNeedsDisplay()
    }

    @objc public func metersOnly() {
        mode = .metersOnly
        setNeedsDisplay()
    }

    @objc public func milesOnly() {
        mode = .milesOnly
        setNeedsDisplay()
    }

    @objc public func metersAndMiles() {
        mode = .metersAndMiles
        setNeedsDisplay()
    }

    // MARK: - Drawing

    public override func draw(_ rect: CGRect) {
        guard let scales = currentScales,
              let context = UIGraphicsGetCurrentContext() else { return }
        drawer.draw(scales: scales, in: rect, context: context)
    }

    public override var intrinsicContentSize: CGSize {
        guard let scales = currentScales else { return .zero }
        return drawer.intrinsicSize(for: scales)
    }
}
