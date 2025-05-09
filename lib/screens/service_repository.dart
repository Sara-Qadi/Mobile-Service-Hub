// service_repository.dart

List<Map<String, dynamic>> allServices = [];

void addService(Map<String, dynamic> service) {
  allServices.add(service);
}

List<Map<String, dynamic>> getAllServices() {
  return allServices;
}
