import { DateProvider } from '../../domain/ports/services/DateProvider';

export class SystemDateProvider implements DateProvider {
  now() { return new Date(); }
  addSeconds(date: Date, seconds: number) {
    return new Date(date.getTime() + seconds * 1000);
  }
}
