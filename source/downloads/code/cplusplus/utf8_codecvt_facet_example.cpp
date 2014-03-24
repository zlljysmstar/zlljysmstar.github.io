#include <iostream>
#include <fstream>
#include <cstdio>
#include <sstream>
#include <vector>
#include <locale>
#include <iterator>
#include <cstring>
#include <iterator>
#include <algorithm>
#include <cstring>
using namespace std;
#include "boost/program_options/detail/convert.hpp"
#include "boost/program_options/detail/utf8_codecvt_facet.hpp"
using namespace boost;

typedef wchar_t ucs4_t;

int main()
{
    std::locale old_locale;
    std::locale utf8_locale(old_locale,new boost::program_options::detail::utf8_codecvt_facet());

    // std::locale::global(utf8_locale);
    // std::locale::global(std::locale("en_US.UTF-8"));
    
    // std::vector<ucs4_t> from_file;
    std::wifstream ifs("data.ucd");
    ifs.imbue(utf8_locale);
    ucs4_t item = 0;
    std::wstring s;
    while (ifs >> item)
    {
        // from_file.push_back(item);
        s.push_back(item);
    }
    
    wcout<<s.size()<<endl;
    std::wofstream ofs("123");
    ofs.imbue(utf8_locale);
  
    ofs<<s<<endl;

    return 0;
}

