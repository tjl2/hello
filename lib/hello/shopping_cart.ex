defmodule Hello.ShoppingCart do
  @moduledoc """
  The ShoppingCart context.
  """

  import Ecto.Query, warn: false
  alias Hello.Repo
  alias Hello.Catalog
  alias Hello.ShoppingCart.{Cart,CartItem}

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts()
      [%Cart{}, ...]

  """
  def list_carts do
    Repo.all(Cart)
  end

  @doc """
  Gets a single cart.

  Raises `Ecto.NoResultsError` if the Cart does not exist.

  ## Examples

      iex> get_cart!(123)
      %Cart{}

      iex> get_cart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart!(id), do: Repo.get!(Cart, id)

  @doc """
  Fetches a cart and joins the cart items, and their products so that we have
  the full cart populated with all preloaded data
  """
  def get_cart_by_user_uuid(user_uuid) do
    Repo.one(
      from(c in Cart,
        where: c.user_uuid == ^user_uuid,
        left_join: i in assoc(c, :items),
        left_join: p in assoc(i, :product),
        order_by: [asc: i.inserted_at],
        preload: [items: {i, product: p}]
      )
    )
  end

  @doc """
  Accepts a user UUID instead of attributes, which we use to populate the
  user_uuid field. If the insert is successful, we reload the cart contents by
  calling a private reload_cart/1 function, which simply calls
  get_cart_by_user_uuid/1 to refetch data

  """
  def create_cart(user_uuid) do
    %Cart{user_uuid: user_uuid}
    |> Cart.changeset(%{})
    |> Repo.insert()
    |> case do
      {:ok, cart} -> {:ok, reload_cart(cart)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp reload_cart(%Cart{} = cart), do: get_cart_by_user_uuid(cart.user_uuid)

  @doc """
  our new add_item_to_cart/2 function which accepts a cart struct and a product
  struct from the catalog. We used an upsert operation against our repo to
  either insert a new cart item into the database, or increase the quantity by
  one if it already exists in the cart. This is accomplished via the on_conflict
  and conflict_target options, which tells our repo how to handle an insert
  conflict
  """
  def add_item_to_cart(%Cart{} = cart, %Catalog.Product{} = product) do
    %CartItem{quantity: 1, price_when_carted: product.price}
    |> CartItem.changeset(%{})
    |> Ecto.Changeset.put_assoc(:cart, cart)
    |> Ecto.Changeset.put_assoc(:product, product)
    |> Repo.insert(
      on_conflict: [inc: [quantity: 1]],
      conflict_target: [:cart_id, :product_id]
    )
  end

  @doc """
  Issue a Repo.delete_all call with a query to delete the cart item in our cart
  that matches the product ID. Finally, we reload the cart contents by calling
  reload_cart/1.
  """
  def remove_item_from_cart(%Cart{} = cart, product_id) do
    {1, _} =
      Repo.delete_all(
        from(i in CartItem,
          where: i.cart_id == ^cart.id,
          where: i.product_id == ^product_id
        )
      )

    {:ok, reload_cart(cart)}
  end

  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(cart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart(%Cart{} = cart, attrs) do
    # we take the cart struct and cast the user input to a cart changeset,
    # except this time we use Ecto.Changeset.cast_assoc/3 to cast the nested
    # item data into CartItem changesets. Remember the hidden_inputs_for/1 call
    # in our cart form template? That hidden ID data is what allows Ecto's
    # cast_assoc to map item data back to existing item associations in the
    # cart. Next we use Ecto.Multi.new/0, which you may not have seen before.
    # Ecto's Multi is a feature that allows lazily defining a chain of named
    # operations to eventually execute inside a database transaction. Each
    # operation in the multi chain receives the values from the previous steps
    # and executes until a failed step is encountered. When an operation fails,
    # the transaction is rolled back and an error is returned, otherwise the
    # transaction is committed. For our multi operations, we start by issuing an
    # update of our cart, which we named :cart. After the cart update is issued,
    # we perform a multi delete_all operation, which takes the updated cart and
    # applies our zero-quantity logic. We prune any items in the cart with zero
    # quantity by returning an ecto query that finds all cart items for this
    # cart with an empty quantity. Calling Repo.transaction/1 with our multi
    # will execute the operations in a new transaction and we return the success
    # or failure result to the caller just like the original function.
    changeset =
      cart
      |> Cart.changeset(attrs)
      |> Ecto.Changeset.cast_assoc(:items, with: &CartItem.changeset/2)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:cart, changeset)
    |> Ecto.Multi.delete_all(:discarded_items, fn %{cart: cart} ->
      from(i in CartItem, where: i.cart_id == ^cart.id and i.quantity == 0)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{cart: cart}} -> {:ok, cart}
      {:error, :cart, changeset, _changes_so_far} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Cart{} = cart) do
    Repo.delete(cart)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart changes.

  ## Examples

      iex> change_cart(cart)
      %Ecto.Changeset{data: %Cart{}}

  """
  def change_cart(%Cart{} = cart, attrs \\ %{}) do
    Cart.changeset(cart, attrs)
  end

  alias Hello.ShoppingCart.CartItem

  @doc """
  Returns the list of cart_items.

  ## Examples

      iex> list_cart_items()
      [%CartItem{}, ...]

  """
  def list_cart_items do
    Repo.all(CartItem)
  end

  @doc """
  Gets a single cart_item.

  Raises `Ecto.NoResultsError` if the Cart item does not exist.

  ## Examples

      iex> get_cart_item!(123)
      %CartItem{}

      iex> get_cart_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart_item!(id), do: Repo.get!(CartItem, id)

  @doc """
  Creates a cart_item.

  ## Examples

      iex> create_cart_item(%{field: value})
      {:ok, %CartItem{}}

      iex> create_cart_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart_item(attrs \\ %{}) do
    %CartItem{}
    |> CartItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cart_item.

  ## Examples

      iex> update_cart_item(cart_item, %{field: new_value})
      {:ok, %CartItem{}}

      iex> update_cart_item(cart_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart_item(%CartItem{} = cart_item, attrs) do
    cart_item
    |> CartItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cart_item.

  ## Examples

      iex> delete_cart_item(cart_item)
      {:ok, %CartItem{}}

      iex> delete_cart_item(cart_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart_item(%CartItem{} = cart_item) do
    Repo.delete(cart_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart_item changes.

  ## Examples

      iex> change_cart_item(cart_item)
      %Ecto.Changeset{data: %CartItem{}}

  """
  def change_cart_item(%CartItem{} = cart_item, attrs \\ %{}) do
    CartItem.changeset(cart_item, attrs)
  end

  def total_item_price(%CartItem{} = item) do
    Decimal.mult(item.product.price, item.quantity)
  end

  def total_cart_price(%Cart{} = cart) do
    Enum.reduce(cart.items, 0, fn item, acc ->
      item
      |> total_item_price()
      |> Decimal.add(acc)
    end)
  end

  def prune_cart_items(%Cart{} = cart) do
    {_, _} = Repo.delete_all(from(i in CartItem, where: i.cart_id == ^cart.id))
    {:ok, reload_cart(cart)}
  end
end
