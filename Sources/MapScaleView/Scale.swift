import CoreGraphics

/// A single scale entry: a formatted text label and the pixel width of the bar.
public struct Scale {
    public let text: String
    public let length: CGFloat

    public init(text: String, length: CGFloat) {
        self.text = text
        self.length = length
    }
}

/// A pair of scales displayed on two lines (e.g. metric on top, imperial below).
public struct Scales {
    public let top: Scale
    public let bottom: Scale?

    public init(top: Scale, bottom: Scale? = nil) {
        self.top = top
        self.bottom = bottom
    }
}
