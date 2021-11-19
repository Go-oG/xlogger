package com.goog.xlogger;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Create by luoheng on 2019-09-04.
 */
class Utils {

  /**
   * obtain int from map.
   *
   * @param map
   * @param key
   * @return
   */
  static Integer getInt(Map map, String key) {
    try {
      Object val = map.get(key);
      if (val != null) {
        return Integer.valueOf(val.toString());
      }
    } catch (Exception ignored) {
    }
    return null;
  }

  /**
   * obtain long from map.
   *
   * @param map
   * @param key
   * @return
   */
  static Long getLong(Map map, String key) {
    try {
      Object val = map.get(key);
      if (val != null) {
        return Long.valueOf(val.toString());
      }
    } catch (Exception ignored) {
    }
    return null;
  }

  /**
   * obtain string from map.
   *
   * @param map
   * @param key
   * @return
   */
  static String getString(Map map, String key) {
    try {
      Object val = map.get(key);
      if (val != null) {
        return val.toString();
      }
    } catch (Exception ignored) {
    }
    return null;
  }

  /**
   * @param obj
   * @return
   */
  static String getString(Object obj) {
    if (obj == null) {
      return "";
    }
    return obj.toString();
  }

  /**
   * str is empty.
   *
   * @param str
   * @return
   */
  static boolean isEmpty(String str) {
    return str == null || str.isEmpty();
  }

  /**
   * str is not empty.
   *
   * @param str
   * @return
   */
  static boolean isNotEmpty(String str) {
    return !isEmpty(str);
  }

  /**
   * obtain map from map.
   *
   * @param map
   * @param key
   * @return
   */
  @SuppressWarnings("unchecked")
  static Map<String, String> getStringMap(Map map, String key) {
    try {
      Map m = (Map) map.get(key);
      if (m == null) {
        return null;
      }
      Map<String, String> toStringMap = new HashMap<>();
      for (Object k : m.keySet()) {
        toStringMap.put(getString(k), getString(m.get(k)));
      }
      return toStringMap;
    } catch (Exception ignored) {
    }
    return null;
  }

  /**
   * recursive delete file.
   *
   * @param fileOrDirectory
   * @param deleteSelf      if need delete self.
   */
  static void deleteRecursive(File fileOrDirectory, boolean deleteSelf) {
    if (fileOrDirectory == null) {
      return;
    }
    if (fileOrDirectory.isDirectory()) {
      File[] files = fileOrDirectory.listFiles();
      if (files != null) {
        for (File child : files) {
          deleteRecursive(child, true);
        }
      }
    }
    if (deleteSelf) {
      fileOrDirectory.delete();
    }
  }

}
