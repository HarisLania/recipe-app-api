from django.test import SimpleTestCase
from app import calc

class AddFunctionTests(SimpleTestCase):
    """
    Testing add function
    """
    def test_add(self):
        res = calc.add(4, 5)
        self.assertEqual(res, 9)

    def test_subtract(self):
        res = calc.subtract(5, 4)
        self.assertEqual(res, 1)