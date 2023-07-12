#include <iostream>
#include <string>
#include <regex>
#include <sstream>
#include <vector>
#include <sys/ioctl.h>
#include <unistd.h>

std::vector<std::string> split_string(const std::string& str) {
    std::istringstream iss(str);
    std::vector<std::string> words((std::istream_iterator<std::string>(iss)), std::istream_iterator<std::string>());
    return words;
}

std::string remove_color_codes(const std::string& str) {
    std::regex color_codes("\\x1b\\[[0-9;]*m");
    return std::regex_replace(str, color_codes, "");
}

void print_color_string(const std::string& color_string) {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

    std::vector<std::string> words = split_string(color_string);
    std::string current_line;
    int current_length = 0;

    for (const auto& word : words) {
        std::string no_color_word = remove_color_codes(word);
        int no_color_length = no_color_word.length();

        if (current_length + no_color_length >= w.ws_col) {
            std::cout << current_line << std::endl;
            current_line = word + ' ';
            current_length = no_color_length + 1;
        } else {
            current_line += word + ' ';
            current_length += no_color_length + 1;
        }
    }

    std::cout << current_line << std::endl;
}

int main() {
    std::string color_string;
    std::getline(std::cin, color_string);
    print_color_string(color_string);
    return 0;
}

