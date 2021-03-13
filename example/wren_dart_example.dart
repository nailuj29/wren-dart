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

  var vm = VM(ffi.DynamicLibrary.open(libraryPath),
      Configuration(writeFn: ffi.Pointer.fromFunction(write)));

  vm.interpret('test', 'System.print("Hello, world!")');
}
