defmodule MyEnum do
  @spec reverse(Enum.t()) :: list()
  def reverse(enumerable) when is_list(enumerable) do
    do_reverse(enumerable)
  end

  def reverse(enumerable) when is_map(enumerable) do
    enumerable |> Map.to_list() |> reverse()
  end

  defp do_reverse(_enumerable, acc \\ [])

  defp do_reverse([], acc), do: acc

  defp do_reverse([head | tail], acc) do
    do_reverse(tail, [head | acc])
  end

  @spec map(Enum.t(), (any() -> any())) :: list()
  def map(enumerable, fun) when is_list(enumerable) do
    do_map(enumerable, fun)
  end

  def map(enumerable, fun) when is_map(enumerable) do
    enumerable |> Map.to_list() |> map(fun)
  end

  defp do_map(_enumerable, _fun, acc \\ [])

  defp do_map([], _fun, acc), do: reverse(acc)

  defp do_map([head | tail], fun, acc) do
    do_map(tail, fun, [fun.(head) | acc])
  end

  @spec uniq_by(Enum.t(), (any() -> any())) :: list()
  def uniq_by(enumerable, fun) when is_list(enumerable) do
    do_uniq_by(enumerable, fun)
  end

  def uniq_by(enumerable, fun) when is_map(enumerable) do
    enumerable |> Map.to_list() |> do_uniq_by(fun)
  end

  defp do_uniq_by(_enumerable, _fun, acc \\ %{})

  defp do_uniq_by([], _fun, acc) do
    map(acc, fn {_k, v} -> v end)
  end

  defp do_uniq_by([head | tail], fun, acc) do
    value = fun.(head)

    case acc do
      %{^value => _} -> do_uniq_by(tail, fun, acc)
      %{} -> do_uniq_by(tail, fun, Map.put(acc, value, head))
    end
  end
end
