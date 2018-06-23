defmodule BoyleTest do
  use ExUnit.Case, async: false
  require Logger
  doctest Boyle

  @tag timeout: 600_000
  test "creating new environment with some dependencies" do
    env_name = "sample_environment_with_number_module#{Enum.random(1..10_000)}"
    assert_that_env_is_not_on_the_list_of_envs(env_name)
    assert_that_number_module_is_not_loaded()
    Boyle.mk(env_name)

    Boyle.activate(env_name)
    assert env_name == Boyle.active_env_name()
    Boyle.install({:number, "~> 0.5.7"})
    assert_that_number_module_works_properly()
    Boyle.deactivate()
    assert nil == Boyle.active_env_name()
    assert_that_number_module_is_not_loaded()

    Boyle.activate(env_name)
    assert env_name == Boyle.active_env_name()
    assert_that_number_module_works_properly()
    Boyle.deactivate()
    assert nil == Boyle.active_env_name()
    assert_that_number_module_is_not_loaded()

    Boyle.rm(env_name)
    assert_that_env_is_not_on_the_list_of_envs(env_name)
  end

  @tag :skip
  test "sth" do
  end

  defp assert_that_env_is_not_on_the_list_of_envs(env_name) do
    {:ok, envs_list} = Boyle.list()
    assert env_name not in envs_list
  end

  defp assert_that_number_module_is_not_loaded do
    error =
      try do
        Code.eval_string("Number.Currency.number_to_currency(123)")
      rescue
        error -> error
      end
    assert error == %UndefinedFunctionError{
      arity: 1,
      exports: nil,
      function: :number_to_currency,
      module: Number.Currency,
      reason: nil}
  end

  defp assert_that_number_module_works_properly() do
    random_1 = Enum.random(1..9)
    random_2 = Enum.random(100..999)
    random_3 = Enum.random(10..99)
    full_number = random_1 * 1000 + random_2 + random_3/100
    full_number_string = "$#{random_1},#{random_2}.#{random_3}"
    Logger.debug(full_number_string)
    assert full_number_string == Number.Currency.number_to_currency(full_number)
  end
end
