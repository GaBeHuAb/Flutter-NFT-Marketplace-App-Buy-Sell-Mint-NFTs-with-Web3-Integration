import 'package:flutter/foundation.dart';

class NFTCardProvider extends ChangeNotifier {
  bool _showBidForm = false;
  bool get showBidForm => _showBidForm;
  set showBidForm(bool value) {
    _showBidForm = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
