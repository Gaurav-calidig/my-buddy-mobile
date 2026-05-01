import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/pref_keys.dart';
import '../utils/shared_pref.dart';

class DateFormatCubit extends Cubit<String> {
  DateFormatCubit() : super('DD/MM/YYYY') {
    _loadFormat();
  }

  Future<void> _loadFormat() async {
    final savedFormat = await SharedPref().read(PrefKeys.dateFormat);
    if (savedFormat != null) {
      emit(savedFormat);
    }
  }

  Future<void> setFormat(String format) async {
    await SharedPref().write(PrefKeys.dateFormat, format);
    emit(format);
  }
}
