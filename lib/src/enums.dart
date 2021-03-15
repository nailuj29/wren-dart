enum WType {
  boolean,
  number,
  foreign,
  list,
  map,
  nullType,
  string,

  // The object is of a type that isn't accessible by the C API.
  unknown
}
