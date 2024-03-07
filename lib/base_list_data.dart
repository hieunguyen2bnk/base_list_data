library base_list_data;

import 'package:base_list_data/api_throw.dart';

class BaseListData<T, Y> {
  final Function(ApiThrow e) onError;
  final void Function(void Function()) onRerender;
  final Future<List<T>> Function(int page, int limit) onLoadMore;
  final Y key;
  final List<T> initList;

  BaseListData({
    required this.key,
    this.limit = 10,
    this.initList = const [],
    required this.onRerender,
    required this.onLoadMore,
    required this.onError,
  }) {
    list.addAll(initList);
  }

  final List<T> list = [];
  bool max = false;
  int limit;
  bool _loading = false;
  int _page = 0;
  int _count = 0;
  String? error;

  bool get loadingMore => _page > 0 && _loading;

  bool get loading => _page == 0 && _loading;

  Future<void> getList({reset = false}) async {
    try {
      if (!reset && (_loading || max)) return;

      onRerender(() {
        _loading = true;
        error = null;

        if (reset) {
          list.clear();
          list.addAll(initList);
          _page = 0;
          max = false;
        }
      });

      ++_count;
      final currentCount = _count + 0;

      final r = await onLoadMore(_page + 1, limit);

      if (currentCount != _count) return;

      onRerender(() {
        list.addAll(r);
        _page += 1;
        _loading = false;

        if (r.length < limit) max = true;
      });
    } on ApiThrow catch (e) {
      onRerender(() {
        _loading = false;
        error = e.name;
      });

      onError(e);
    }
  }

  void updateItem(int i, T newData) {
    if (i == -1) return;

    onRerender(() {
      list.removeAt(i);
      list.insert(i, newData);
    });
  }
}
