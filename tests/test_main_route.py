import unittest
from unittest.mock import patch, Mock

from app import app

class TestHome(unittest.TestCase):
    @patch('app.get_db_connection')
    def test_home(self, mock_get_db_connection):
        mock_cursor = Mock()
        mock_cursor.fetchall.return_value = [
            (1, "kennys", 1.12, 1.20, 31.2, "kennys.png"),
            (2, "s1mple", 1.24, 1.33, 41.5, "s1mple.png"),
            (3, "m0nesy", 1.23, 1.31, 39.4, "m0nesy.png"),
            (4, "zywoo", 1.33, 1.39, 41.3, "zywoo.png"),
        ]

        mock_conn = Mock()
        mock_conn.cursor.return_value = mock_cursor

        mock_get_db_connection.return_value = mock_conn

        with app.test_client() as client:
            response = client.get('/')
            self.assertEqual(response.status_code, 200)
            self.assertIn(b'kennys', response.data)
            self.assertIn(b's1mple', response.data)
            self.assertIn(b'm0nesy', response.data)
            self.assertIn(b'zywoo', response.data)
