import 'package:leelame/features/order/data/models/order_api_model.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';

abstract interface class IOrderRemoteDatasource {
  Future<OrderApiModel?> createOrder(OrderApiModel orderModel);
  Future<OrderApiModel?> updateOrderDetails(OrderApiModel orderModel);
  Future<OrderApiModel?> updateOrderStatus(String orderId, OrderStatus status);
  Future<OrderApiModel?> getOrderById(String orderId);
}
