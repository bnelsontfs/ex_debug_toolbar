defmodule ExDebugToolbar.Data.MapTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable, Collection}

  describe "collectable protocol" do
    test "init_collection/1 return a map" do
      assert Collectable.init_collection(%{}) == %{}
    end
  end

  describe "collection protocol" do
    test "change/2 sets values in the collection" do
      assert Collection.change(%{}, %{foo: :bar}) == %{foo: :bar}
    end

    test "change/2 overwrites collection values" do
      collection = %{key: "old value", foo: :bar}
      updated_collection = Collection.change(collection, %{key: "new value"})
      assert updated_collection == %{key: "new value", foo: :bar}
    end
  end
end
