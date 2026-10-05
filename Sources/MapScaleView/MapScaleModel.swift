import CoreGraphics
import Darwin

/// Mirrors Android MapScaleModel: computes a human-readable scale from map zoom + latitude.
final class MapScaleModel {

    // Earth equatorial circumference
    private static let equatorMetres: Double = 40_075_016.686

    // World width in points at zoom 0 (Google Maps iOS / OSM standard).
    // iOS map zoom and UIKit drawing are both in points, so no screen-scale factor applies.
    private static let tileSize: Double = 256

    private static let metricDistances: [Int] = [
        1, 2, 5, 10, 20, 50, 100, 200, 500,
        1_000, 2_000, 5_000, 10_000, 20_000, 50_000,
        100_000, 200_000, 500_000, 1_000_000
    ]

    // Below one mile the bar steps in feet; from one mile up it steps in whole miles,
    // so the label always matches the bar length exactly.
    private static let footDistances: [Int] = [
        1, 2, 5, 10, 20, 50, 100, 200, 500, 1_000, 2_000
    ]

    private static let mileDistances: [Int] = [
        1, 2, 5, 10, 20, 50, 100, 200, 500, 1_000
    ]

    // metres per foot
    private static let metresPerFoot: Double = 0.3048
    private static let feetPerMile: Double = 5280

    /// Resolution: metres per screen point at given zoom and latitude.
    private static func resolution(zoom: Float, latitude: Double) -> Double {
        guard zoom >= 0, abs(latitude) <= 90 else { return 0 }
        let latRad = latitude * .pi / 180
        return (equatorMetres / tileSize) * cos(latRad) / pow(2.0, Double(zoom))
    }

    /// Compute metric scale (metres / km).
    static func metricScale(zoom: Float, latitude: Double, maxWidth: CGFloat) -> Scale? {
        let res = resolution(zoom: zoom, latitude: latitude)
        guard res > 0 else { return nil }
        let maxMetres = res * Double(maxWidth)
        for dist in metricDistances.reversed() {
            if Double(dist) <= maxMetres {
                let points = CGFloat(Double(dist) / res)
                let text = dist < 1_000 ? "\(dist) m" : "\(dist / 1_000) km"
                return Scale(text: text, length: points)
            }
        }
        return nil
    }

    /// Compute imperial scale (feet / miles).
    static func imperialScale(zoom: Float, latitude: Double, maxWidth: CGFloat) -> Scale? {
        let res = resolution(zoom: zoom, latitude: latitude)
        guard res > 0 else { return nil }
        // convert res to feet/point
        let resFeet = res / metresPerFoot
        let maxFeet = resFeet * Double(maxWidth)

        for miles in mileDistances.reversed() {
            let feet = Double(miles) * feetPerMile
            if feet <= maxFeet {
                return Scale(text: "\(miles) mi", length: CGFloat(feet / resFeet))
            }
        }
        for feet in footDistances.reversed() {
            if Double(feet) <= maxFeet {
                return Scale(text: "\(feet) ft", length: CGFloat(Double(feet) / resFeet))
            }
        }
        return nil
    }

    static func scales(
        zoom: Float,
        latitude: Double,
        maxWidth: CGFloat,
        mode: MapScaleView.UnitMode
    ) -> Scales? {
        switch mode {
        case .metersOnly:
            guard let m = metricScale(zoom: zoom, latitude: latitude, maxWidth: maxWidth) else { return nil }
            return Scales(top: m)
        case .milesOnly:
            guard let i = imperialScale(zoom: zoom, latitude: latitude, maxWidth: maxWidth) else { return nil }
            return Scales(top: i)
        case .metersAndMiles:
            guard let m = metricScale(zoom: zoom, latitude: latitude, maxWidth: maxWidth) else { return nil }
            let i = imperialScale(zoom: zoom, latitude: latitude, maxWidth: maxWidth)
            return Scales(top: m, bottom: i)
        }
    }
}
