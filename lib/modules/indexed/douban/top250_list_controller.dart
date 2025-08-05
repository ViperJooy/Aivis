import 'package:aivis/app/controller/base_controller.dart';
import 'package:aivis/models/doubantop250/top250_list_model.dart';
import 'package:aivis/requests/top250_request.dart';

class Top250ListController extends BasePageController<Top250ItemModel> {
  final String title;
  Top250ListController(this.title);
  final Top250Request request = Top250Request();

  @override
  Future<List<Top250ItemModel>> getData(int page, int pageSize) async {
    return await request.getTop250List(
      pageIndex: page,
    );
  }
}
