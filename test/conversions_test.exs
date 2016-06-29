defmodule Mesquitte.ConversionsTest do
  use ExUnit.Case, async: true

  import Mesquitte.Conversions

  test "to_bool" do
    assert to_bool(1) == true
    assert to_bool(0) == false
  end

  test "to_int" do
    assert to_int(true) == 1
    assert to_int(false) == 0
  end
end
