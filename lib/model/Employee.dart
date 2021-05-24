class Employee {
  Employee({
    this.name,
    this.number,
    this.idCardNumber,
    this.organizationName,
    this.city,
    this.district,
    this.state,
    this.addressLine1,
    this.departmentName,
  });

  Employee.empty({
    this.name = '',
    this.number = 0,
    this.idCardNumber = 0,
    this.organizationName = '',
    this.city = '',
    this.district = '',
    this.state = '',
    this.addressLine1 = '',
    this.departmentName = '',
  });

  Employee.error({
    this.name = 'Error',
    this.number = 0,
    this.idCardNumber = 0,
    this.organizationName = 'Error',
    this.city = 'Error',
    this.district = 'Error',
    this.state = 'Error',
    this.addressLine1 = 'Error',
    this.departmentName = 'Error',
  });

  final String name;
  final int number;
  final int idCardNumber;
  final String organizationName;
  final String city;
  final String district;
  final String state;
  final String addressLine1;
  final String departmentName;
}
