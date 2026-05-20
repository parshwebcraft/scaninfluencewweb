import SwiftUI

struct BusinessCardPreview: View {
    let contact: ContactProfile
    let namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(alignment: .top) {
                ProfileAvatarView(initials: contact.initials, size: 72)
                    .matchedGeometryEffect(id: "avatar", in: namespace)

                Spacer()

                Image(systemName: "wave.3.right.circle.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(.teal, .white.opacity(0.12))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(contact.name)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                Text(contact.designation)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.72))
                Text(contact.company)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.teal)
            }

            HStack(spacing: 12) {
                Label("QR", systemImage: "qrcode")
                Label("NFC", systemImage: "sensor.tag.radiowaves.forward")
                Spacer()
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white.opacity(0.72))
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 260, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.32), radius: 30, y: 18)
    }
}
