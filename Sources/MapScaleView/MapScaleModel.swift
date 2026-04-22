import CoreGraphics
import Darwin

/// Mirrors Android MapScaleModel: computes a human-readable scale from map zoom + latitude.
final class MapScaleModel {

    // Earth equatorial circumference
    private static let equatorMetres: Double = 40_075_016.686
    private static let equatorFeet: Double   = 131_479_713.537

    // Tile size at zoom 0 (Google Maps / OSM standard)
    private static let tileSize: Double = 256

    private static let metricDistances: [Int] = [
        1, 2, 5, 10, 20, 50, 100, 200, 500,
        1_000, 2_000, 5_000, 10_000, 20_000, 50_000,
        100_000, 200_000, 500_000, 1_000_000
    ]

    private static let imperialDistances: [Int] = [
        1, 2, 5, 10, 20, 50, 100, 200, 500,
        1_000, 2_000, 5_000, 10_000, 20_000, 50_000,
        100_000, 200_000, 500_000, 1_000_000
    ]

    // metres per foot
    private static let metresPerFoot: Double = 0.3048
    private static let feetPerMile: Int = 5280

    /// Resolution: metres per screen point at given zoom and latitude.
    private static func resolution(zoom: Float, latitude: Double, density: CGFloat) -> Double {
        guard zoom >= 0, abs(latitude) <= 90 else { return 0 }
        let latRad = latitude * .pi / 180
        return (equatorMetres / tileSize / Double(density)) * cos(latRad) / pow(2.0, Double(zoom))
    }

    /// Compute metric scale (metres / km).
    static func metricScale(zoom: Float, latitude: Double, maxWidth: CGFloat, density: CGFloat) -> Scale? {
        let res = resolution(zoom: zoom, latitude: latitude, density: density)
        guard res > 0 else { return nil }
        let maxMetres = res * Double(maxWidth)
        for dist in metricDistances.reversed() {
            if Double(dist) <= maxMetres {
                let pixels = CGFloat(Double(dist) / res)
                let text = dist < 1_000 ? "\(dist) m" : "\(dist / 1_000) km"
                return Scale(text: text, length: pixels)
            }
        }
        return nil
    }

    /// Compute imperial scale (feet / miles).
    static func imperialScale(zoom: Float, latitude: Double, maxWidth: CGFloat, density: CGFloat) -> Scale? {
        let res = resolution(zoom: zoom, latitude: latitude, density: density)
        guard res > 0 else { return nil }
        // convert res to feet/point
        let resFeet = res / metresPerFoot
        let maxFeet = resFeet * Double(maxWidth)

        // distances in feet
        for dist in imperialDistances.reversed() {
            if Double(dist) <= maxFeet {
                let pixels = CGFloat(Double(dist) / resFeet)
                let text = dist < feetPerMile ? "\(dist) ft" : "\(dist / feetPerMile) mi"
                return Scale(text: text, length: pixels)
            }
        }
        return nil
    }

    static func scales(
        zoom: Float,
        latitude: Double,
        maxWidth: CGFloat,
        density: CGFloat,
        mode: MapScaleView.UnitMode
    ) -> Scales? {
        switch mode {
        case .metersOnly:
            guard let m = metricScale(zoom: zoom, latitude: latitude, maxWidth: maxWidth, density: density) else { return nil }
            return Scales(top: m)
        case .milesOnly:
            guard let i = imperialScale(zoom: zoom, latitude: latitude, maxWidth: maxWidth, density: density) else { return nil }
            return Scales(top: i)
        case .metersAndMiles:
            guard let m = metricScale(zoom: zoom, latitude: latitude, maxWidth: maxWidth, density: density) else { return nil }
            let i = imperialScale(zoom: zoom, latitude: latitude, maxWidth: maxWidth, density: density)
            return Scales(top: m, bottom: i)
        }
    }
}
