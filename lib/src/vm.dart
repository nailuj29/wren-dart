import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:wren_dart/src/enums.dart';
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

  ///Ensures that the foreign method stack has at least [numSlots] available for
  /// use, growing the stack if needed.
  ///
  /// Does not shrink the stack if it has more than enough slots.
  ///
  /// It is an error to call this from a finalizer.
  void ensureSlots(int numSlots) {
    _bindings.wrenEnsureSlots(_ptrVm, numSlots);
  }

  /// Returns the number of slots available to the current foreign method.
  int get slotCount => _bindings.wrenGetSlotCount(_ptrVm);

  /// Stores the [T] [value] in slot [index].
  void setSlot<T>(int index, T value) {
    if (T == double) {
      _bindings.wrenSetSlotDouble(_ptrVm, index, value as double);
    } else if (T == bool) {
      _bindings.wrenSetSlotBool(_ptrVm, index, value as bool);
    } else if (T == String) {
      _bindings.wrenSetSlotBytes(
          _ptrVm, index, (value as String).toNativeUtf8().cast(), value.length);
    } else {
      throw ArgumentError('Invalid type for setSlot');
    }
  }

  /// Sets the slot at [index] to null
  void setSlotNull(int index) {
    _bindings.wrenSetSlotNull(_ptrVm, index);
  }

  /// Gets the type of the slot at [index]
  WType getSlotType(int index) {
    return WType.values[_bindings.wrenGetSlotType(_ptrVm, index)];
  }

  /// Gets the value of the slot at [index] as a [T]
  T getSlot<T>(int index) {
    if (T == double) {
      if (getSlotType(index) != WType.number) {
        throw TypeError();
      }
      return _bindings.wrenGetSlotDouble(_ptrVm, index) as T;
    } else if (T == bool) {
      if (getSlotType(index) != WType.boolean) {
        throw TypeError();
      }
      return _bindings.wrenGetSlotBool(_ptrVm, index) as T;
    } else if (T == String) {
      if (getSlotType(index) != WType.string) {
        throw TypeError();
      }
      return _bindings
          .wrenGetSlotString(_ptrVm, index)
          .cast<Utf8>()
          .toDartString() as T;
    } else {
      throw ArgumentError('Invalid type for getSlot');
    }
  }
}
