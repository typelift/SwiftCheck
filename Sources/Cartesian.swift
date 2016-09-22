//
//  Cartesian.swift.gyb
//  SwiftCheck
//
//  Created by Adam Kuipers on 5/10/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

// This is a GYB generated file; any changes will be overwritten
// during the build phase. Edit the template instead,
// found in Templates/Cartesian.swift.gyb


extension Gen /*: Cartesian*/ {


	/// Zips together 3 generators generator of tuples.
	public static func zip<A1, A2, A3>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>) -> Gen<(A1, A2, A3)> {
		return Gen
			.zip(
				.zip(ga1, ga2),
				ga3
			).map {
				($0.0, $0.1, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, transform: @escaping (A1, A2, A3) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3).map(transform)
	}

	/// Zips together 4 generators generator of tuples.
	public static func zip<A1, A2, A3, A4>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>) -> Gen<(A1, A2, A3, A4)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3),
				ga4
			).map {
				($0.0, $0.1, $0.2, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, transform: @escaping (A1, A2, A3, A4) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4).map(transform)
	}

	/// Zips together 5 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>) -> Gen<(A1, A2, A3, A4, A5)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4),
				ga5
			).map {
				($0.0, $0.1, $0.2, $0.3, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, transform: @escaping (A1, A2, A3, A4, A5) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5).map(transform)
	}

	/// Zips together 6 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>) -> Gen<(A1, A2, A3, A4, A5, A6)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5),
				ga6
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, transform: @escaping (A1, A2, A3, A4, A5, A6) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6).map(transform)
	}

	/// Zips together 7 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>) -> Gen<(A1, A2, A3, A4, A5, A6, A7)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6),
				ga7
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7).map(transform)
	}

	/// Zips together 8 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7),
				ga8
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8).map(transform)
	}

	/// Zips together 9 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8),
				ga9
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9).map(transform)
	}

	/// Zips together 10 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9),
				ga10
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10).map(transform)
	}

	/// Zips together 11 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10),
				ga11
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11).map(transform)
	}

	/// Zips together 12 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11),
				ga12
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12).map(transform)
	}

	/// Zips together 13 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12),
				ga13
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13).map(transform)
	}

	/// Zips together 14 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13),
				ga14
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14).map(transform)
	}

	/// Zips together 15 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14),
				ga15
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $0.13, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15).map(transform)
	}

	/// Zips together 16 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15),
				ga16
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $0.13, $0.14, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16).map(transform)
	}

	/// Zips together 17 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16),
				ga17
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $0.13, $0.14, $0.15, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17).map(transform)
	}

	/// Zips together 18 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17),
				ga18
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $0.13, $0.14, $0.15, $0.16, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18).map(transform)
	}

	/// Zips together 19 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, _ ga19 : Gen<A19>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18),
				ga19
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $0.13, $0.14, $0.15, $0.16, $0.17, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, _ ga19 : Gen<A19>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18, ga19).map(transform)
	}

	/// Zips together 20 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, _ ga19 : Gen<A19>, _ ga20 : Gen<A20>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18, ga19),
				ga20
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $0.13, $0.14, $0.15, $0.16, $0.17, $0.18, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, _ ga19 : Gen<A19>, _ ga20 : Gen<A20>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18, ga19, ga20).map(transform)
	}

	/// Zips together 21 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, _ ga19 : Gen<A19>, _ ga20 : Gen<A20>, _ ga21 : Gen<A21>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18, ga19, ga20),
				ga21
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $0.13, $0.14, $0.15, $0.16, $0.17, $0.18, $0.19, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, _ ga19 : Gen<A19>, _ ga20 : Gen<A20>, _ ga21 : Gen<A21>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18, ga19, ga20, ga21).map(transform)
	}

	/// Zips together 22 generators generator of tuples.
	public static func zip<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, _ ga19 : Gen<A19>, _ ga20 : Gen<A20>, _ ga21 : Gen<A21>, _ ga22 : Gen<A22>) -> Gen<(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22)> {
		return Gen
			.zip(
				.zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18, ga19, ga20, ga21),
				ga22
			).map {
				($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $0.9, $0.10, $0.11, $0.12, $0.13, $0.14, $0.15, $0.16, $0.17, $0.18, $0.19, $0.20, $1)
			}
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, _ ga11 : Gen<A11>, _ ga12 : Gen<A12>, _ ga13 : Gen<A13>, _ ga14 : Gen<A14>, _ ga15 : Gen<A15>, _ ga16 : Gen<A16>, _ ga17 : Gen<A17>, _ ga18 : Gen<A18>, _ ga19 : Gen<A19>, _ ga20 : Gen<A20>, _ ga21 : Gen<A21>, _ ga22 : Gen<A22>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10, ga11, ga12, ga13, ga14, ga15, ga16, ga17, ga18, ga19, ga20, ga21, ga22).map(transform)
	}
}
