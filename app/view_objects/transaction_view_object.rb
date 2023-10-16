#frozen_string_literal: true

class TransactionViewObject
  attr_reader :transaction, :view_context

  delegate(
    :date,
    :id,
    :memo,
    :note,
    to: :transaction,
  )

  def initialize(transaction:, view_context:)
    @transaction = transaction
    @view_context = view_context
  end

  def account_columns
    if transaction.split?
      row(additional_classes: 'col-span-2') {
        view_context.link_to(
          'view split details',
          view_context.split_transaction_path(
            transaction.id,
            page: view_context.params.fetch(:page, nil)
          ),
          class: 'col-span-2 items-center link-primary',
        )
      }
    else
      row { transaction.account_debited&.name } +
        row { transaction.account_credited&.name }
    end
  end

  def actions
    if transaction.split?
      view_context.render_button_menu(links: [edit_split_link, delete_action])
    else
      view_context.render_button_menu(links: [edit_action, delete_action, split_action])
    end
  end

  def amount
    view_context.number_to_currency(transaction.amount)
  end

  private

  def delete_action
    {
      label: 'Delete',
      data: { confirm: 'Are you sure?' },
      method: :delete,
      target: :_top,
      url: view_context.transaction_path(id),
    }
  end

  def edit_action
    {
      label: 'Edit',
      url: view_context.edit_transaction_path(
        id,
        page: view_context.params.fetch(:page, nil),
      ),
    }
  end

  def edit_split_link
    {
      label: 'Edit Split',
      url: view_context.new_split_transaction_path(
        page: view_context.params.fetch(:page, nil),
        parent_id: id,
      ),
    }
  end

  def split_action
    {
      label: 'Split',
      url: view_context.new_split_transaction_path(
        page: view_context.params.fetch(:page, nil),
        parent_id: id,
      ),
    }
  end

  def row(additional_classes: nil)
    view_context.content_tag(
      :div,
      class: ['text-sm px-3 py-1', additional_classes].compact.join(' '),
    ) { yield }
  end
end