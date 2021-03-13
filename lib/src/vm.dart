import 'dart:ffi';

import 'package:ffi/ffi.dart';
import './generated_bindings.dart';

class Configuration {
  Pointer<NativeFunction<WrenWriteFn>>? writeFn;

  Configuration({this.writeFn});
}

class VM {
  late Pointer<WrenVM> _ptrVm;
  late WrenBindings _bindings;

  VM(DynamicLibrary lib, Configuration config) {
    _bindings = WrenBindings(lib);
    var wrenConfig = calloc<WrenConfiguration>();
    _bindings.wrenInitConfiguration(wrenConfig);
    if (config.writeFn != null) {
      wrenConfig.ref.writeFn = config.writeFn!;
    }
    _ptrVm = _bindings.wrenNewVM(wrenConfig);
  }

  /// Runs [source], a string of Wren source code in a new fiber in this VM in the
  /// context of resolved [moduleName].
  int interpret(String moduleName, String source) {
    return _bindings.wrenInterpret(
        _ptrVm, moduleName.toNativeUtf8().cast(), source.toNativeUtf8().cast());
  }

  /// Frees the memory used by the VM. It shouldn't be used after this
  void free() {
    _bindings.wrenFreeVM(_ptrVm);
  }

  /// Immediately run the garbage collector to free unused memory.
  void collectGarbage() {
    _bindings.wrenCollectGarbage(_ptrVm);
  }
}
