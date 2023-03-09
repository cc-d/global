import unittest

from rcconf import *

class TestRCConf(unittest.TestCase):
    
    def test_lowercase_var_name(self):
        line = 'variable="value"'
        self.assertFalse(is_upper_evar(line))
        
    def test_uppercase_var_name(self):
        line = 'VARIABLE="value"'
        self.assertTrue(is_upper_evar(line))
        
    def test_uppercase_var_name_with_export(self):
        line = 'export VARIABLE="value"'
        self.assertTrue(is_upper_evar(line))
        
    def test_uppercase_var_name_with_declare(self):
        line = 'declare -i VARIABLE=10'
        self.assertTrue(is_upper_evar(line))
        
    def test_uppercase_var_name_with_declare_and_export(self):
        line = 'declare -x VARIABLE="value"'
        self.assertTrue(is_upper_evar(line))
        
    def test_uppercase_var_name_with_single_quotes(self):
        line = "VARIABLE='value'"
        self.assertTrue(is_upper_evar(line))
        
    def test_uppercase_var_name_with_double_quotes(self):
        line = 'VARIABLE="value"'
        self.assertTrue(is_upper_evar(line))
        
    def test_uppercase_var_name_with_process_substitution(self):
        line = 'sorted_files=<(ls | sort)'
        self.assertFalse(is_upper_evar(line))
        
    def test_uppercase_var_name_with_command_substitution(self):
        line = 'files=$(ls)'
        self.assertFalse(is_upper_evar(line))
        
    def test_uppercase_var_name_with_here_document(self):
        line = 'text=$(cat << EOF\nThis is a multiline\nstring.\nEOF\n)'
        self.assertFalse(is_upper_evar(line))
        
    def test_uppercase_var_name_with_array_assignment(self):
        line = 'colors=("red" "green" "blue")'
        self.assertFalse(is_upper_evar(line))
        
    def test_uppercase_var_name_with_associative_array_assignment(self):
        line = 'fruit=( ["apple"]="red" ["banana"]="yellow" ["grape"]="purple" )'
        self.assertFalse(is_upper_evar(line))
        
    def test_uppercase_var_name_with_multiple_assignments(self):
        line = 'VAR1="value1" VAR2="value2" VARIABLE="value"'
        self.assertTrue(is_upper_evar(line))
