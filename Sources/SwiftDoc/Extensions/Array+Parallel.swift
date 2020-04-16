import Dispatch

public extension RandomAccessCollection {
    func parallelMap<T>(_ transform: (Element) throws -> T) throws -> [T] {
        guard count > 1 else {
            return try map(transform)
        }

        let indices = Array(self.indices)
        var results = [Result<T, Error>?](repeating: nil, count: count)

        let queue = DispatchQueue(label: #function)
        DispatchQueue.concurrentPerform(iterations: count) { (iteration) in
            do {
                let transformed = try transform(self[indices[iteration]])
                queue.sync {
                    results[iteration] = .success(transformed)
                }
            } catch {
                queue.sync {
                    results[iteration] = .failure(error)
                }
            }
        }

        return try results.map { try $0!.get() }
    }

    func parallelCompactMap<T>(transform: (Element) throws -> T?) throws -> [T] {
        return try parallelMap(transform).compactMap { $0 }
    }

    func parallelFlatMap<T>(transform: (Element) throws -> [T]) throws -> [T] {
        return try parallelMap(transform).flatMap { $0 }
    }

    func parallelForEach(_ body: (Element) throws -> Void) throws {
        _ = try parallelMap(body)
    }
}
