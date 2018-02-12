public enum TelephoneError: Error {
    case webservice(String)
    case cache(String)
    case fileStorage(String)
}
