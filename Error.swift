public enum TelephoneError: Error {
    case webservice(String)
    case cashe(String)
    case fileStorage(String)
}
