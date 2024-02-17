using System;

namespace Shared.Database
{
    /// <summary>
    /// ��������������� ����� ��� ������ � Nullable-������
    /// </summary>
    public static class NullableHelper
    {
        public static object DBNullConvertFrom<T>(Nullable<T> value) where T : struct
        {
            if (value.HasValue)
                return value.Value;
            else
                return System.DBNull.Value;
        }

        public static object DBNullConvertFrom<T>(T value) where T : class
        {
            if (value != null)
                return value;
            else
                return System.DBNull.Value;
        }

        public static Nullable<T> DBNullConvertNullableTo<T>(object value) where T : struct
        {
            if (value == null || value == System.DBNull.Value)
                return null;
            else
                return (T)value;
        }

        public static T DBNullConvertTo<T>(object value) where T : class
        {
            if (value == null || value == System.DBNull.Value)
                return null;
            else
                return (T)value;
        }

        /// <summary>
        /// ���������� null, ���� �������� ������ ������ ��� null. 
        /// � ��������� ������ ���������� �������� ������.
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static string NullIfEmpty(string str)
        {
            return string.IsNullOrEmpty(str) ? null : str;
        }

        /// <summary>
        /// ���������� null, ���� �������� ������ null ��� Trim �������� ������ - ������ ������.
        /// � ��������� ������ ���������� Trim �������� ������.
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static string NullIfTrimEmpty(string str)
        {
            string trimmed = str == null ? null : str.Trim();
            return string.IsNullOrEmpty(trimmed) ? null : trimmed;
        }

        /// <summary>
        /// ���������� true, ���� �������� ������ null ��� Trim �������� ������ - ������ ������
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static bool IsNullOrTrimEmpty(string str)
        {
            if (str == null)
                return true;
            else
                return str.Trim() == string.Empty;
        }
    }
}
