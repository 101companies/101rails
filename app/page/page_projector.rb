class PageProjector < Sequent::Core::Projector

  on InvoicePaidEvent do |event|
    update_record(InvoiceRecord, event) do |record|
      record.pay_date = event.date_paid
    end
  end
  
end
