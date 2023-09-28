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
          class: 'col-span-2 items-center text-sm text-green-700 hover:text-green-900',
        )
      }
    else
      row { transaction.account_debited&.name } +
        row { transaction.account_credited&.name }
    end
  end

  def actions
    if transaction.split?
      edit_split_action + delete_action
    else
      edit_action + delete_action + split_action
    end
  end

  def amount
    view_context.number_to_currency(transaction.amount)
  end

  private

  def delete_action
    view_context.link_to(
      'Delete',
      view_context.transaction_path(id),
      class: 'text-red-700 hover:text-red-900',
      data: { confirm: 'Are you sure?' },
      method: :delete,
      target: :_top,
    )
  end

  def edit_action
    view_context.link_to(
      'Edit',
      view_context.edit_transaction_path(
        id,
        page: view_context.params.fetch(:page, nil),
      ),
      class: 'text-green-700 hover:text-green-900',
    )
  end

  def edit_split_action
    view_context.link_to(
      'Edit Split',
      view_context.new_split_transaction_path(
        page: view_context.params.fetch(:page, nil),
        parent_id: id,
      ),
      class: 'text-green-700 hover:text-green-900',
    )
  end

  def split_action
    view_context.link_to(
      'Split',
      view_context.new_split_transaction_path(
        page: view_context.params.fetch(:page, nil),
        parent_id: id,
      ),
      class: 'text-green-700 hover:text-green-900',
    )
  end

  def row(additional_classes: nil)
    view_context.content_tag(
      :div,
      class: ['text-sm px-3 py-1', additional_classes].compact.join(' '),
    ) { yield }
  end
end