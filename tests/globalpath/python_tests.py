import sys
import os
import unittest
import tempfile
from os.path import join, dirname, abspath

sys.path.insert(0, abspath(join(dirname(__file__), "..", "..")))
from scripts.gentreefiles import create_tree, treere, linetype

TESTSTRS = (
    '''
django-arm-test-runner/
|-- django_arm_test_runner/
|   |-- __init__.py
|   |-- runners.py
|-- tests/
|   |-- __init__.py
|   |-- test_runners.py
|-- setup.py
|-- README.md
|--  LICENSE
''',
    '''
project_root/
├── src/
│   ├── main.py
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── helpers.py
│   │   └── data/
│   │       ├── __init__.py
│   │       ├── loaders.py
│   │       └── transformers.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── order.py
│   └── api/
│       ├── __init__.py
│       ├── routes.py
│       └── middlewares/
│           ├── __init__.py
│           ├── auth.py
│           └── logging.py
├── tests/
│   ├── __init__.py
│   ├── test_helpers.py
│   ├── test_loaders.py
│   └── test_transformers.py
└── configs/
    ├── config.json
    ├── dev.json
    └── prod.json
''',
)


class TestTreeCreation(unittest.TestCase):
    def setUp(self):
        # Create a temporary directory for testing purposes
        self.test_dir = tempfile.mkdtemp()

    def test_directory_creation(self):
        tree_string = """
        test_dir_1/
        """
        created_paths = create_tree(tree_string, base_path=self.test_dir)
        self.assertTrue(os.path.isdir(created_paths[0]))

    def test_file_creation(self):
        tree_string = """
        test_file_1.txt
        """
        created_paths = create_tree(tree_string, base_path=self.test_dir)
        self.assertTrue(os.path.isfile(created_paths[0]))

    def test_complex_structure(self):
        tree_string = """
        dir1/
            file1.txt
            dir2/
                file2.txt
        """
        created_paths = create_tree(tree_string, base_path=self.test_dir)
        self.assertEqual(len(created_paths), 4)
        self.assertTrue(os.path.isdir(created_paths[0]))
        self.assertTrue(os.path.isfile(created_paths[1]))
        self.assertTrue(os.path.isdir(created_paths[2]))
        self.assertTrue(os.path.isfile(created_paths[3]))

    def test_given_teststrs(self):
        for tree_string in TESTSTRS:
            created_paths = create_tree(tree_string, base_path=self.test_dir)
            for i, path in enumerate(created_paths):
                curdepth = treere(path)[0]
                if path.endswith("/"):
                    self.assertTrue(os.path.isdir(path))
                nextpath = (
                    created_paths[i + 1]
                    if i + 1 < len(created_paths)
                    else None
                )
                if nextpath is not None:
                    nextdepth = treere(nextpath)[0]
                    if nextdepth > curdepth:
                        self.assertTrue(os.path.isdir(path))

    def test_empty_string(self):
        created_paths = create_tree("", base_path=self.test_dir)
        self.assertEqual(len(created_paths), 0)

    def tearDown(self):
        # Cleanup the temporary directory after tests
        for root, dirs, files in os.walk(self.test_dir, topdown=False):
            for name in files:
                os.remove(os.path.join(root, name))
            for name in dirs:
                os.rmdir(os.path.join(root, name))
        os.rmdir(
            self.test_dir
        )  # Ensure the base temp directory is also removed


if __name__ == '__main__':
    unittest.main()
