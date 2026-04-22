import XCTest
@testable import MapScaleView

final class MapScaleModelTests: XCTestCase {

    private let density: CGFloat = 3.0
    private let maxWidth: CGFloat = 175

    // At zoom 7, latitude 45 (central Canada), metric scale should be in the tens-of-km range.
    func testMetricScaleAtZoom7() throws {
        let scale = MapScaleModel.metricScale(zoom: 7, latitude: 45, maxWidth: maxWidth, density: density)
        let s = try XCTUnwrap(scale)
        XCTAssertGreaterThan(s.length, 0)
        XCTAssertTrue(s.text.hasSuffix("km") || s.text.hasSuffix("m"), "Unexpected label: \(s.text)")
    }

    func testImperialScaleAtZoom7() throws {
        let scale = MapScaleModel.imperialScale(zoom: 7, latitude: 45, maxWidth: maxWidth, density: density)
        let s = try XCTUnwrap(scale)
        XCTAssertGreaterThan(s.length, 0)
        XCTAssertTrue(s.text.hasSuffix("mi") || s.text.hasSuffix("ft"), "Unexpected label: \(s.text)")
    }

    // At zoom 2, should still return a valid scale.
    func testLowZoom() {
        let scale = MapScaleModel.metricScale(zoom: 2, latitude: 45, maxWidth: maxWidth, density: density)
        XCTAssertNotNil(scale)
    }

    // At zoom 15, bar should be in the metre range.
    func testHighZoomMetric() throws {
        let scale = MapScaleModel.metricScale(zoom: 15, latitude: 45, maxWidth: maxWidth, density: density)
        let s = try XCTUnwrap(scale)
        XCTAssertTrue(s.text.hasSuffix("m"), "Expected metres at zoom 15, got: \(s.text)")
    }

    // Invalid inputs should return nil gracefully.
    func testInvalidZoom() {
        let scale = MapScaleModel.metricScale(zoom: -1, latitude: 45, maxWidth: maxWidth, density: density)
        XCTAssertNil(scale)
    }

    func testInvalidLatitude() {
        let scale = MapScaleModel.metricScale(zoom: 7, latitude: 95, maxWidth: maxWidth, density: density)
        XCTAssertNil(scale)
    }

    // metersAndMiles mode should return both top and bottom.
    func testBothUnits() throws {
        let scales = MapScaleModel.scales(zoom: 7, latitude: 45, maxWidth: maxWidth, density: density, mode: .metersAndMiles)
        let s = try XCTUnwrap(scales)
        XCTAssertNotNil(s.bottom)
    }

    // metersOnly mode should have no bottom scale.
    func testMetersOnlyMode() throws {
        let scales = MapScaleModel.scales(zoom: 7, latitude: 45, maxWidth: maxWidth, density: density, mode: .metersOnly)
        let s = try XCTUnwrap(scales)
        XCTAssertNil(s.bottom)
    }
}
