import UIKit

/// Renders the scale bar onto a UIView's draw context.
/// Mirrors Android's Drawer class: horizontal bar with vertical end caps and text label(s).
final class Drawer {

    private let config: ViewConfig

    // Layout constants (points)
    private let textBarGap: CGFloat   = 2   // gap between text and bar
    private let capHeight: CGFloat    = 6   // height of vertical end caps
    private let outlineWidth: CGFloat        // derived from strokeWidth * 2

    init(config: ViewConfig) {
        self.config = config
        self.outlineWidth = config.strokeWidth * 2
    }

    // MARK: - Size calculation

    func intrinsicSize(for scales: Scales) -> CGSize {
        let font = UIFont.systemFont(ofSize: config.textSize)
        let topAttr = attributes(font: font, color: config.color)

        let topTextSize  = (scales.top.text as NSString).size(withAttributes: topAttr)
        let maxBarWidth  = max(scales.top.length, scales.bottom?.length ?? 0)
        let contentWidth = max(topTextSize.width, maxBarWidth) + config.strokeWidth

        var totalHeight = topTextSize.height + textBarGap + capHeight + config.strokeWidth
        if let bottom = scales.bottom {
            let botTextSize = (bottom.text as NSString).size(withAttributes: topAttr)
            totalHeight += capHeight + textBarGap + botTextSize.height
        }

        return CGSize(width: contentWidth + outlineWidth, height: totalHeight + outlineWidth)
    }

    // MARK: - Drawing

    func draw(scales: Scales, in rect: CGRect, context: CGContext) {
        let font    = UIFont.systemFont(ofSize: config.textSize)
        let topAttr = attributes(font: font, color: config.color)
        let topTextSize = (scales.top.text as NSString).size(withAttributes: topAttr)

        let barY = outlineWidth / 2 + topTextSize.height + textBarGap

        // Draw top text
        let textX = outlineWidth / 2
        (scales.top.text as NSString).draw(at: CGPoint(x: textX, y: outlineWidth / 2), withAttributes: topAttr)

        // Build bar path for top scale
        let path = UIBezierPath()
        appendBar(to: path, startX: outlineWidth / 2, barY: barY, length: scales.top.length, capHeight: capHeight)

        // Build bar path for bottom scale if present
        if let bottom = scales.bottom {
            let botBarY = barY + capHeight
            appendBar(to: path, startX: outlineWidth / 2, barY: botBarY, length: bottom.length, capHeight: capHeight)
            let botTextY = botBarY + capHeight + textBarGap
            (bottom.text as NSString).draw(at: CGPoint(x: textX, y: botTextY), withAttributes: topAttr)
        }

        // Draw outline (white halo) then main stroke
        if config.outlineEnabled {
            config.outlineColor.setStroke()
            path.lineWidth = outlineWidth
            path.lineCapStyle = .square
            path.stroke()
        }

        config.color.setStroke()
        path.lineWidth = config.strokeWidth
        path.lineCapStyle = .square
        path.stroke()
    }

    // MARK: - Private

    private func appendBar(to path: UIBezierPath, startX: CGFloat, barY: CGFloat, length: CGFloat, capHeight: CGFloat) {
        // left cap
        path.move(to: CGPoint(x: startX, y: barY))
        path.addLine(to: CGPoint(x: startX, y: barY + capHeight))
        // horizontal bar
        path.move(to: CGPoint(x: startX, y: barY + capHeight / 2))
        path.addLine(to: CGPoint(x: startX + length, y: barY + capHeight / 2))
        // right cap
        path.move(to: CGPoint(x: startX + length, y: barY))
        path.addLine(to: CGPoint(x: startX + length, y: barY + capHeight))
    }

    private func attributes(font: UIFont, color: UIColor) -> [NSAttributedString.Key: Any] {
        [.font: font, .foregroundColor: color]
    }
}
