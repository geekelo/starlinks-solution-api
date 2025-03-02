require 'prawn'

module Api::V1::RenewalPdfGeneratorHelper
  def self.generate_renewal_pdf(renewal)
    pdf = Prawn::Document.new
    pdf.text "Starlink Renewal #{renewal.status.capitalize}", size: 24, style: :bold, align: :center
    pdf.move_down 20
    pdf.text "Kit ID: #{renewal.starlink_kit_id}", size: 16, style: :bold
    pdf.move_down 10
    pdf.text "Amount: #{renewal.amount}", size: 16, style: :bold
    pdf.move_down 10
    pdf.text "Deadline: #{renewal.deadline}", size: 16, style: :bold
    pdf.move_down 10
    pdf.text "Status: #{renewal.status.capitalize}", size: 16, style: :bold
    pdf.move_down 10
    pdf.text "Date of Renewal: #{renewal.date_of_renewal}", size: 16, style: :bold
    pdf.render
  end
end
