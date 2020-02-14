import Dispatch

extension Array {
    func parallelMap<T>(_ transform: (Element) throws -> T) throws -> [T] {
        guard count > 1 else {
            return try map(transform)
        }

        var results = [(index: Int, result: Result<T, Error>)]()
        results.reserveCapacity(count)

        let queue = DispatchQueue(label: "org.swiftdoc.swift-doc.parallelMap")
        withoutActuallyEscaping(transform) { escapingtransform in
            DispatchQueue.concurrentPerform(iterations: count) { (index) in
                do {
                    let transformed = try escapingtransform(self[index])
                    queue.sync {
                        results.append((index, .success(transformed)))
                    }
                } catch {
                    queue.sync {
                        results.append((index, .failure(error)))
                    }
                }
            }
        }

        return try results.sorted { $0.index < $1.index }
                          .map { try $0.result.get() }
    }

    func parallelCompactMap<T>(transform: (Element) throws -> T?) throws -> [T] {
        return try parallelMap(transform).compactMap { $0 }
    }

    func parallelFlatMap<T>(transform: (Element) throws -> [T]) throws -> [T] {
        return try parallelMap(transform).flatMap { $0 }
    }
}
