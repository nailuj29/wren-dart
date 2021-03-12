import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:wren_dart/wren_dart.dart';
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart';

void write(ffi.Pointer<WrenVM> vm, ffi.Pointer<ffi.Int8> string) {
  stdout.write(string.cast<Utf8>().toDartString());
}

void main(List<String> args) {
  var libraryPath = path.join(Directory.current.path, 'wren', 'libwren.so');
  if (Platform.isMacOS) {
    libraryPath = path.join(Directory.current.path, 'wren', 'libwren.dylib');
  }
  if (Platform.isWindows) {
    libraryPath =
        path.join(Directory.current.path, 'wren', 'Debug', 'wren.dll');
  }

  var bindings = WrenBindings(ffi.DynamicLibrary.open(libraryPath));
  var configPtr = calloc<WrenConfiguration>();
  bindings.wrenInitConfiguration(configPtr);
  var config = configPtr.ref;
  config.writeFn = ffi.Pointer.fromFunction<WrenWriteFn>(write);

  var vm = bindings.wrenNewVM(configPtr);

  var result = bindings.wrenInterpret(vm, 'my_module'.toNativeUtf8().cast(),
      'System.print(\"I am running in a VM!\")'.toNativeUtf8().cast());
}
