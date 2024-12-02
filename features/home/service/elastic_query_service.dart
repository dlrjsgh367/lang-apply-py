import 'package:chodan_flutter_app/models/profile_model.dart';

class ElasticQueryService {
  static Map<String, dynamic> defaultQuery(int page, dynamic currentPosition) {
    return {
      "query": {
        "bool": {"must": [], 'should': [], 'minimum_should_match': 0},
      },
      "size": 20,
      "from": 20 * (page - 1),
      "sort": [
        {
          "_geo_distance": {
            "order": "asc",
            "unit": "km",
            "distance_type": "plane",
            "location": {
              "lat": currentPosition['lat'],
              "lon": currentPosition['lng'],
            }
          }
        }
      ],
    };
  }

  static Map<String, dynamic> defaultScrollQuery(dynamic currentPosition) {
    return {
      "query": {
        "bool": {"must": [], 'should': [], 'minimum_should_match': 0},
      },
      "sort": [
        {
          "_geo_distance": {
            "order": "desc",
            "unit": "km",
            "distance_type": "plane",
            "location": {
              "lat": currentPosition['lat'],
              "lon": currentPosition['lng'],
            }
          }
        }
      ],
      "size": 500,
    };
  }

  static Map<String, dynamic> defaultMapScrollQuery(dynamic currentPosition,dynamic selectMapPosition) {
    return {
      "query": {
        "bool": {
          "must": [],
          'should': [],
          'minimum_should_match': 0,
          "filter": {
            "geo_distance": {
              "distance": "5km",
              "location": {
                "lat": selectMapPosition['lat'],
                "lon": selectMapPosition['lng'],
              }
            }
          }
        },
      },
      "sort": [
        {
          "_geo_distance": {
            "order": "desc",
            "unit": "km",
            "distance_type": "plane",
            "location": {
              "lat": currentPosition['lat'],
              "lon": currentPosition['lng'],
            }
          }
        }
      ],
      "size": 500,
    };
  }

  static setGenderFilter(List<int> gender, dynamic body) {
    if (gender.isNotEmpty) {
      body['query']['bool']['must'].add({
        "terms": {"recruitmentCondition.jpSex": gender}
      });
    } else {
      body['query']['bool']['must'].removeWhere((key, value) =>
          key == 'terms' && value.key == 'recruitmentCondition.jpSex');
    }
  }

  static setAgeFilter(List<int> age, dynamic body) {
    if (age.isNotEmpty) {
      body['query']['bool']['must'].add({
        "terms": {"ageList": age}
      });
    } else {
      body['query']['bool']['must'].removeWhere(
          (key, value) => key == 'terms' && value.key == 'ageList');
    }
  }

  static setAreaFilter(List address, dynamic body) {
    if (address.isNotEmpty) {
      body['query']['bool']['must'].add({
        "terms": {"adIdx": address}
      });
    } else {
      body['query']['bool']['must']
          .removeWhere((key, value) => key == 'terms' && value.key == 'adIdx');
    }
  }

  static setAreaSort(List<Map<String, dynamic>> addressLocation, dynamic body) {
    if (addressLocation.isNotEmpty) {
      body['sort'][0]['_geo_distance'] = {
        "distance_type": "plane",
        "order": "asc",
        "unit": "km",
        "location": {
          "lat": addressLocation[0]['lat'],
          "lon": addressLocation[0]['lng']
        }
      };
    } else {
      body['sort'].removeWhere((key, value) => key == '_geo_distance');
    }
  }

  static setCareerTypeFilter(List<int> careerType, dynamic body) {
    if (careerType.isNotEmpty) {
      body['query']['bool']['must'].add({
        "terms": {"recruitmentCondition.jpCareerType": careerType}
      });
    } else {
      body['query']['bool']['must'].removeWhere((key, value) =>
          key == 'terms' && value.key == 'recruitmentCondition.jpCareerType');
    }
  }

  static setWorkRangeFilter(List<int> workRange, dynamic body) {
    if (workRange.isNotEmpty) {
      body['query']['bool']['must'].add({
        "terms": {"workCondition.wpIdx": workRange}
      });
    } else {
      body['query']['bool']['must'].removeWhere(
          (key, value) => key == 'terms' && value.key == 'workCondition.wpIdx');
    }
  }

  static setWorkTypeFilter(List<int> workType, dynamic body) {
    if (workType.isNotEmpty) {
      body['query']['bool']['must'].add({
        "terms": {"workCondition.wtIdx": workType}
      });
    } else {
      body['query']['bool']['must'].removeWhere(
          (key, value) => key == 'terms' && value.key == 'workCondition.wtIdx');
    }
  }

  static setOccuTypeFilter(List occuType, dynamic body) {
    if (occuType.isNotEmpty) {
      body['query']['bool']['must'].add({
        "terms": {"workInfo.jobList.joIdx": occuType}
      });
    } else {
      body['query']['bool']['must'].removeWhere((key, value) =>
          key == 'terms' && value.key == 'workInfo.jobList.joIdx');
    }
  }

  static setSalaryTypeFilter(String salaryType, dynamic body) {
    if (salaryType.isNotEmpty) {
      body['query']['bool']['must'].add({
        "match": {"workCondition.jpSalaryType": salaryType}
      });
    } else {
      body['query']['bool']['must'].removeWhere((key, value) =>
          key == 'match' && value.key == 'workCondition.jpSalaryType');
    }
  }

  static setSalaryFilter(int salary, dynamic body) {
    if (salary > 0) {
      body['query']['bool']['must'].add({
        "range": {
          "workCondition.jpSalary": {'gte': salary}
        }
      });
    } else {
      body['query']['bool']['must'].removeWhere((key, value) =>
          key == 'range' && value.key == 'workCondition.jpSalary');
    }
  }

  static setTitleFilter(String keyword, dynamic body) {
    if (keyword.isNotEmpty) {
      String queryString = "((*$keyword*) OR ($keyword))";
      body['query']['bool']['must'].add({
        "query_string": {
          "fields": ["jpTitle", 'jpCompanyName'],
          "query": queryString
        }
      });
    } else {
      body['query']['bool']['must']
          .removeWhere((key, value) => key == 'query_string');
    }
  }
}
