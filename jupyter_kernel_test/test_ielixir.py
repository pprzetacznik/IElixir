import unittest
import jupyter_kernel_test as jkt


class IElixirKernelTests(jkt.KernelTests):
    kernel_name = "ielixir"

    language_name = "elixir"

    code_hello_world = 'IO.puts("hello, world")'

    completion_samples = [
        {
            "text": "En",
            "matches": {"um"},
        },
        {
            "text": "Enu",
            "matches": {"m"},
        },
        {
            "text": "Enum",
            "matches": {"Enum", "Enumerable"},
        },
    ]

    complete_code_samples = ["1", 'IO.puts("abc")', "fun = fn x -> x*2 end"]
    incomplete_code_samples = ["case x do", "fun = fn x -> x*2"]
    invalid_code_samples = ["asdf", "case x of", "1aaa"]


if __name__ == "__main__":
    unittest.main()
