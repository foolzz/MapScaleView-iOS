import XCTest
@testable import MapScaleView

final class MapScaleModelTests: XCTestCase {

    private let maxWidth: CGFloat = 175

    // At zoom 7, latitude 45 (central Canada), metric scale should be in the tens-of-km range.
    func testMetricScaleAtZoom7() throws {
        let scale = MapScaleModel.metricScale(zoom: 7, latitude: 45, maxWidth: maxWidth)
        let s = try XCTUnwrap(scale)
        XCTAssertGreaterThan(s.length, 0)
        XCTAssertTrue(s.text.hasSuffix("km") || s.text.hasSuffix("m"), "Unexpected label: \(s.text)")
    }

    func testImperialScaleAtZoom7() throws {
        let scale = MapScaleModel.imperialScale(zoom: 7, latitude: 45, maxWidth: maxWidth)
        let s = try XCTUnwrap(scale)
        XCTAssertGreaterThan(s.length, 0)
        XCTAssertTrue(s.text.hasSuffix("mi") || s.text.hasSuffix("ft"), "Unexpected label: \(s.text)")
    }

    // At zoom 2, should still return a valid scale.
    func testLowZoom() {
        let scale = MapScaleModel.metricScale(zoom: 2, latitude: 45, maxWidth: maxWidth)
        XCTAssertNotNil(scale)
    }

    // At zoom 15, bar should be in the metre range.
    func testHighZoomMetric() throws {
        let scale = MapScaleModel.metricScale(zoom: 15, latitude: 45, maxWidth: maxWidth)
        let s = try XCTUnwrap(scale)
        XCTAssertTrue(s.text.hasSuffix("m"), "Expected metres at zoom 15, got: \(s.text)")
    }

    // Invalid inputs should return nil gracefully.
    func testInvalidZoom() {
        let scale = MapScaleModel.metricScale(zoom: -1, latitude: 45, maxWidth: maxWidth)
        XCTAssertNil(scale)
    }

    func testInvalidLatitude() {
        let scale = MapScaleModel.metricScale(zoom: 7, latitude: 95, maxWidth: maxWidth)
        XCTAssertNil(scale)
    }

    // metersAndMiles mode should return both top and bottom.
    func testBothUnits() throws {
        let scales = MapScaleModel.scales(zoom: 7, latitude: 45, maxWidth: maxWidth, mode: .metersAndMiles)
        let s = try XCTUnwrap(scales)
        XCTAssertNotNil(s.bottom)
    }

    // metersOnly mode should have no bottom scale.
    func testMetersOnlyMode() throws {
        let scales = MapScaleModel.scales(zoom: 7, latitude: 45, maxWidth: maxWidth, mode: .metersOnly)
        let s = try XCTUnwrap(scales)
        XCTAssertNil(s.bottom)
    }

    // Bar length must represent exactly the labelled distance, in points.
    // At zoom 0 on the equator one point is equator/256 metres.
    func testMetricLengthIsInPoints() throws {
        let metresPerPoint = 40_075_016.686 / 256
        let s = try XCTUnwrap(MapScaleModel.metricScale(zoom: 0, latitude: 0, maxWidth: maxWidth))
        XCTAssertEqual(s.text, "10000 km")
        XCTAssertEqual(Double(s.length), 10_000_000 / metresPerPoint, accuracy: 0.001)
    }

    // Mile labels must be whole miles whose bar length matches the label
    // (regression: 20 000 ft used to be labelled "3 mi").
    func testImperialMileLabelsMatchLength() throws {
        for zoom in stride(from: Float(2), through: 18, by: 0.25) {
            let m = try XCTUnwrap(MapScaleModel.metricScale(zoom: zoom, latitude: 45, maxWidth: maxWidth))
            let i = try XCTUnwrap(MapScaleModel.imperialScale(zoom: zoom, latitude: 45, maxWidth: maxWidth))
            let metres = labelledMetres(m.text)
            let imperialMetres = labelledMetres(i.text)
            XCTAssertEqual(Double(i.length) / Double(m.length), imperialMetres / metres, accuracy: 1e-6,
                           "zoom \(zoom): \(m.text) vs \(i.text)")
            XCTAssertLessThanOrEqual(i.length, maxWidth)
        }
    }

    func testThreeMilesIsNeverALabel() throws {
        for zoom in stride(from: Float(2), through: 18, by: 0.1) {
            let i = try XCTUnwrap(MapScaleModel.imperialScale(zoom: zoom, latitude: 45, maxWidth: maxWidth))
            XCTAssertNotEqual(i.text, "3 mi")
        }
    }

    private func labelledMetres(_ text: String) -> Double {
        let parts = text.split(separator: " ")
        let value = Double(parts[0])!
        switch parts[1] {
        case "m": return value
        case "km": return value * 1_000
        case "ft": return value * 0.3048
        case "mi": return value * 5280 * 0.3048
        default: XCTFail("Unknown unit \(text)"); return 0
        }
    }
}
