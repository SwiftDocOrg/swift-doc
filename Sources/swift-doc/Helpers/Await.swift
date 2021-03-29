import Foundation

func _await<T>(_ body: (@escaping (Result<T, Error>) -> Void) -> Void) throws -> T {
    return try _await(body).get()
}

func _await<T>(_ body: (@escaping (T) -> Void) -> Void) -> T {
    let condition = NSCondition()
    var value: T?

    body { output in
        condition.lock {
            value = output
            condition.signal()
        }
    }

    condition.lock {
        while value == nil {
            condition.wait()
        }
    }

    return value!
}

fileprivate extension NSCondition {
    func lock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }

        return try body()
    }
}
